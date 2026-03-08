// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#6366F1'));
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<int> icon = GeneratedColumn<int>(
      'icon', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _viewModeMeta =
      const VerificationMeta('viewMode');
  @override
  late final GeneratedColumn<String> viewMode = GeneratedColumn<String>(
      'view_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('list'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        color,
        icon,
        createdAt,
        archivedAt,
        order,
        isArchived,
        viewMode
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('view_mode')) {
      context.handle(_viewModeMeta,
          viewMode.isAcceptableOrUnknown(data['view_mode']!, _viewModeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      viewMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}view_mode'])!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class ProjectData extends DataClass implements Insertable<ProjectData> {
  final int id;
  final String name;
  final String? description;
  final String color;
  final int? icon;
  final DateTime createdAt;
  final DateTime? archivedAt;
  final int order;
  final bool isArchived;
  final String viewMode;
  const ProjectData(
      {required this.id,
      required this.name,
      this.description,
      required this.color,
      this.icon,
      required this.createdAt,
      this.archivedAt,
      required this.order,
      required this.isArchived,
      required this.viewMode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<int>(icon);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['order'] = Variable<int>(order);
    map['is_archived'] = Variable<bool>(isArchived);
    map['view_mode'] = Variable<String>(viewMode);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      color: Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      order: Value(order),
      isArchived: Value(isArchived),
      viewMode: Value(viewMode),
    );
  }

  factory ProjectData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<int?>(json['icon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      order: serializer.fromJson<int>(json['order']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      viewMode: serializer.fromJson<String>(json['viewMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<int?>(icon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'order': serializer.toJson<int>(order),
      'isArchived': serializer.toJson<bool>(isArchived),
      'viewMode': serializer.toJson<String>(viewMode),
    };
  }

  ProjectData copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? color,
          Value<int?> icon = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> archivedAt = const Value.absent(),
          int? order,
          bool? isArchived,
          String? viewMode}) =>
      ProjectData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        color: color ?? this.color,
        icon: icon.present ? icon.value : this.icon,
        createdAt: createdAt ?? this.createdAt,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
        order: order ?? this.order,
        isArchived: isArchived ?? this.isArchived,
        viewMode: viewMode ?? this.viewMode,
      );
  ProjectData copyWithCompanion(ProjectsCompanion data) {
    return ProjectData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      order: data.order.present ? data.order.value : this.order,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      viewMode: data.viewMode.present ? data.viewMode.value : this.viewMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('order: $order, ')
          ..write('isArchived: $isArchived, ')
          ..write('viewMode: $viewMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, color, icon, createdAt,
      archivedAt, order, isArchived, viewMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt &&
          other.order == this.order &&
          other.isArchived == this.isArchived &&
          other.viewMode == this.viewMode);
}

class ProjectsCompanion extends UpdateCompanion<ProjectData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> color;
  final Value<int?> icon;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> order;
  final Value<bool> isArchived;
  final Value<String> viewMode;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.order = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.viewMode = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.order = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.viewMode = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ProjectData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? color,
    Expression<int>? icon,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? order,
    Expression<bool>? isArchived,
    Expression<String>? viewMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (order != null) 'order': order,
      if (isArchived != null) 'is_archived': isArchived,
      if (viewMode != null) 'view_mode': viewMode,
    });
  }

  ProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? color,
      Value<int?>? icon,
      Value<DateTime>? createdAt,
      Value<DateTime?>? archivedAt,
      Value<int>? order,
      Value<bool>? isArchived,
      Value<String>? viewMode}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      order: order ?? this.order,
      isArchived: isArchived ?? this.isArchived,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<int>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (viewMode.present) {
      map['view_mode'] = Variable<String>(viewMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('order: $order, ')
          ..write('isArchived: $isArchived, ')
          ..write('viewMode: $viewMode')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurringPatternMeta =
      const VerificationMeta('recurringPattern');
  @override
  late final GeneratedColumn<String> recurringPattern = GeneratedColumn<String>(
      'recurring_pattern', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
      'labels', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _voiceNoteMeta =
      const VerificationMeta('voiceNote');
  @override
  late final GeneratedColumn<String> voiceNote = GeneratedColumn<String>(
      'voice_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estimatedMinutesMeta =
      const VerificationMeta('estimatedMinutes');
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
      'estimated_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _spentMinutesMeta =
      const VerificationMeta('spentMinutes');
  @override
  late final GeneratedColumn<int> spentMinutes = GeneratedColumn<int>(
      'spent_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        priority,
        status,
        dueDate,
        createdAt,
        completedAt,
        projectId,
        duration,
        isRecurring,
        recurringPattern,
        parentId,
        labels,
        order,
        voiceNote,
        estimatedMinutes,
        spentMinutes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<TaskData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('recurring_pattern')) {
      context.handle(
          _recurringPatternMeta,
          recurringPattern.isAcceptableOrUnknown(
              data['recurring_pattern']!, _recurringPatternMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('labels')) {
      context.handle(_labelsMeta,
          labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    }
    if (data.containsKey('voice_note')) {
      context.handle(_voiceNoteMeta,
          voiceNote.isAcceptableOrUnknown(data['voice_note']!, _voiceNoteMeta));
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
          _estimatedMinutesMeta,
          estimatedMinutes.isAcceptableOrUnknown(
              data['estimated_minutes']!, _estimatedMinutesMeta));
    }
    if (data.containsKey('spent_minutes')) {
      context.handle(
          _spentMinutesMeta,
          spentMinutes.isAcceptableOrUnknown(
              data['spent_minutes']!, _spentMinutesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id']),
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration']),
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurringPattern: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurring_pattern']),
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id']),
      labels: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}labels']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      voiceNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voice_note']),
      estimatedMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_minutes']),
      spentMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}spent_minutes'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskData extends DataClass implements Insertable<TaskData> {
  final int id;
  final String title;
  final String? description;
  final int priority;
  final int status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? projectId;
  final int? duration;
  final bool isRecurring;
  final String? recurringPattern;
  final int? parentId;
  final String? labels;
  final int order;
  final String? voiceNote;
  final int? estimatedMinutes;
  final int spentMinutes;
  const TaskData(
      {required this.id,
      required this.title,
      this.description,
      required this.priority,
      required this.status,
      this.dueDate,
      required this.createdAt,
      this.completedAt,
      this.projectId,
      this.duration,
      required this.isRecurring,
      this.recurringPattern,
      this.parentId,
      this.labels,
      required this.order,
      this.voiceNote,
      this.estimatedMinutes,
      required this.spentMinutes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<int>(projectId);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurringPattern != null) {
      map['recurring_pattern'] = Variable<String>(recurringPattern);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    if (!nullToAbsent || labels != null) {
      map['labels'] = Variable<String>(labels);
    }
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || voiceNote != null) {
      map['voice_note'] = Variable<String>(voiceNote);
    }
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    map['spent_minutes'] = Variable<int>(spentMinutes);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      priority: Value(priority),
      status: Value(status),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      isRecurring: Value(isRecurring),
      recurringPattern: recurringPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringPattern),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      labels:
          labels == null && nullToAbsent ? const Value.absent() : Value(labels),
      order: Value(order),
      voiceNote: voiceNote == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceNote),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      spentMinutes: Value(spentMinutes),
    );
  }

  factory TaskData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<int>(json['status']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      projectId: serializer.fromJson<int?>(json['projectId']),
      duration: serializer.fromJson<int?>(json['duration']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurringPattern: serializer.fromJson<String?>(json['recurringPattern']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      labels: serializer.fromJson<String?>(json['labels']),
      order: serializer.fromJson<int>(json['order']),
      voiceNote: serializer.fromJson<String?>(json['voiceNote']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      spentMinutes: serializer.fromJson<int>(json['spentMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<int>(status),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'projectId': serializer.toJson<int?>(projectId),
      'duration': serializer.toJson<int?>(duration),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurringPattern': serializer.toJson<String?>(recurringPattern),
      'parentId': serializer.toJson<int?>(parentId),
      'labels': serializer.toJson<String?>(labels),
      'order': serializer.toJson<int>(order),
      'voiceNote': serializer.toJson<String?>(voiceNote),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'spentMinutes': serializer.toJson<int>(spentMinutes),
    };
  }

  TaskData copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          int? priority,
          int? status,
          Value<DateTime?> dueDate = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<int?> projectId = const Value.absent(),
          Value<int?> duration = const Value.absent(),
          bool? isRecurring,
          Value<String?> recurringPattern = const Value.absent(),
          Value<int?> parentId = const Value.absent(),
          Value<String?> labels = const Value.absent(),
          int? order,
          Value<String?> voiceNote = const Value.absent(),
          Value<int?> estimatedMinutes = const Value.absent(),
          int? spentMinutes}) =>
      TaskData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        projectId: projectId.present ? projectId.value : this.projectId,
        duration: duration.present ? duration.value : this.duration,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringPattern: recurringPattern.present
            ? recurringPattern.value
            : this.recurringPattern,
        parentId: parentId.present ? parentId.value : this.parentId,
        labels: labels.present ? labels.value : this.labels,
        order: order ?? this.order,
        voiceNote: voiceNote.present ? voiceNote.value : this.voiceNote,
        estimatedMinutes: estimatedMinutes.present
            ? estimatedMinutes.value
            : this.estimatedMinutes,
        spentMinutes: spentMinutes ?? this.spentMinutes,
      );
  TaskData copyWithCompanion(TasksCompanion data) {
    return TaskData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      duration: data.duration.present ? data.duration.value : this.duration,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurringPattern: data.recurringPattern.present
          ? data.recurringPattern.value
          : this.recurringPattern,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      labels: data.labels.present ? data.labels.value : this.labels,
      order: data.order.present ? data.order.value : this.order,
      voiceNote: data.voiceNote.present ? data.voiceNote.value : this.voiceNote,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      spentMinutes: data.spentMinutes.present
          ? data.spentMinutes.value
          : this.spentMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('projectId: $projectId, ')
          ..write('duration: $duration, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringPattern: $recurringPattern, ')
          ..write('parentId: $parentId, ')
          ..write('labels: $labels, ')
          ..write('order: $order, ')
          ..write('voiceNote: $voiceNote, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('spentMinutes: $spentMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      priority,
      status,
      dueDate,
      createdAt,
      completedAt,
      projectId,
      duration,
      isRecurring,
      recurringPattern,
      parentId,
      labels,
      order,
      voiceNote,
      estimatedMinutes,
      spentMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.projectId == this.projectId &&
          other.duration == this.duration &&
          other.isRecurring == this.isRecurring &&
          other.recurringPattern == this.recurringPattern &&
          other.parentId == this.parentId &&
          other.labels == this.labels &&
          other.order == this.order &&
          other.voiceNote == this.voiceNote &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.spentMinutes == this.spentMinutes);
}

class TasksCompanion extends UpdateCompanion<TaskData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> priority;
  final Value<int> status;
  final Value<DateTime?> dueDate;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int?> projectId;
  final Value<int?> duration;
  final Value<bool> isRecurring;
  final Value<String?> recurringPattern;
  final Value<int?> parentId;
  final Value<String?> labels;
  final Value<int> order;
  final Value<String?> voiceNote;
  final Value<int?> estimatedMinutes;
  final Value<int> spentMinutes;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.duration = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringPattern = const Value.absent(),
    this.parentId = const Value.absent(),
    this.labels = const Value.absent(),
    this.order = const Value.absent(),
    this.voiceNote = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.spentMinutes = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.duration = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringPattern = const Value.absent(),
    this.parentId = const Value.absent(),
    this.labels = const Value.absent(),
    this.order = const Value.absent(),
    this.voiceNote = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.spentMinutes = const Value.absent(),
  }) : title = Value(title);
  static Insertable<TaskData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? priority,
    Expression<int>? status,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? projectId,
    Expression<int>? duration,
    Expression<bool>? isRecurring,
    Expression<String>? recurringPattern,
    Expression<int>? parentId,
    Expression<String>? labels,
    Expression<int>? order,
    Expression<String>? voiceNote,
    Expression<int>? estimatedMinutes,
    Expression<int>? spentMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (projectId != null) 'project_id': projectId,
      if (duration != null) 'duration': duration,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurringPattern != null) 'recurring_pattern': recurringPattern,
      if (parentId != null) 'parent_id': parentId,
      if (labels != null) 'labels': labels,
      if (order != null) 'order': order,
      if (voiceNote != null) 'voice_note': voiceNote,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (spentMinutes != null) 'spent_minutes': spentMinutes,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<int>? priority,
      Value<int>? status,
      Value<DateTime?>? dueDate,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<int?>? projectId,
      Value<int?>? duration,
      Value<bool>? isRecurring,
      Value<String?>? recurringPattern,
      Value<int?>? parentId,
      Value<String?>? labels,
      Value<int>? order,
      Value<String?>? voiceNote,
      Value<int?>? estimatedMinutes,
      Value<int>? spentMinutes}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      projectId: projectId ?? this.projectId,
      duration: duration ?? this.duration,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      parentId: parentId ?? this.parentId,
      labels: labels ?? this.labels,
      order: order ?? this.order,
      voiceNote: voiceNote ?? this.voiceNote,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      spentMinutes: spentMinutes ?? this.spentMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurringPattern.present) {
      map['recurring_pattern'] = Variable<String>(recurringPattern.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (voiceNote.present) {
      map['voice_note'] = Variable<String>(voiceNote.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (spentMinutes.present) {
      map['spent_minutes'] = Variable<int>(spentMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('projectId: $projectId, ')
          ..write('duration: $duration, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringPattern: $recurringPattern, ')
          ..write('parentId: $parentId, ')
          ..write('labels: $labels, ')
          ..write('order: $order, ')
          ..write('voiceNote: $voiceNote, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('spentMinutes: $spentMinutes')
          ..write(')'))
        .toString();
  }
}

class $PomodoroSessionsTable extends PomodoroSessions
    with TableInfo<$PomodoroSessionsTable, PomodoroSessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PomodoroSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('work'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, taskId, duration, startedAt, completedAt, isCompleted, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pomodoro_sessions';
  @override
  VerificationContext validateIntegrity(
      Insertable<PomodoroSessionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PomodoroSessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PomodoroSessionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $PomodoroSessionsTable createAlias(String alias) {
    return $PomodoroSessionsTable(attachedDatabase, alias);
  }
}

class PomodoroSessionData extends DataClass
    implements Insertable<PomodoroSessionData> {
  final int id;
  final int taskId;
  final int duration;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final String type;
  const PomodoroSessionData(
      {required this.id,
      required this.taskId,
      required this.duration,
      required this.startedAt,
      this.completedAt,
      required this.isCompleted,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['duration'] = Variable<int>(duration);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['type'] = Variable<String>(type);
    return map;
  }

  PomodoroSessionsCompanion toCompanion(bool nullToAbsent) {
    return PomodoroSessionsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      duration: Value(duration),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isCompleted: Value(isCompleted),
      type: Value(type),
    );
  }

  factory PomodoroSessionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PomodoroSessionData(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      duration: serializer.fromJson<int>(json['duration']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'duration': serializer.toJson<int>(duration),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'type': serializer.toJson<String>(type),
    };
  }

  PomodoroSessionData copyWith(
          {int? id,
          int? taskId,
          int? duration,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          bool? isCompleted,
          String? type}) =>
      PomodoroSessionData(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        duration: duration ?? this.duration,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        isCompleted: isCompleted ?? this.isCompleted,
        type: type ?? this.type,
      );
  PomodoroSessionData copyWithCompanion(PomodoroSessionsCompanion data) {
    return PomodoroSessionData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      duration: data.duration.present ? data.duration.value : this.duration,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PomodoroSessionData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('duration: $duration, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, taskId, duration, startedAt, completedAt, isCompleted, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PomodoroSessionData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.duration == this.duration &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.isCompleted == this.isCompleted &&
          other.type == this.type);
}

class PomodoroSessionsCompanion extends UpdateCompanion<PomodoroSessionData> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<int> duration;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<bool> isCompleted;
  final Value<String> type;
  const PomodoroSessionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.duration = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.type = const Value.absent(),
  });
  PomodoroSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required int duration,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.type = const Value.absent(),
  })  : taskId = Value(taskId),
        duration = Value(duration),
        startedAt = Value(startedAt);
  static Insertable<PomodoroSessionData> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<int>? duration,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<bool>? isCompleted,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (duration != null) 'duration': duration,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (type != null) 'type': type,
    });
  }

  PomodoroSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? taskId,
      Value<int>? duration,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<bool>? isCompleted,
      Value<String>? type}) {
    return PomodoroSessionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      duration: duration ?? this.duration,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PomodoroSessionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('duration: $duration, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<int> icon = GeneratedColumn<int>(
      'icon', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, name, color, icon, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryData extends DataClass implements Insertable<CategoryData> {
  final int id;
  final String name;
  final String color;
  final int? icon;
  final int order;
  const CategoryData(
      {required this.id,
      required this.name,
      required this.color,
      this.icon,
      required this.order});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<int>(icon);
    }
    map['order'] = Variable<int>(order);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      order: Value(order),
    );
  }

  factory CategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<int?>(json['icon']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<int?>(icon),
      'order': serializer.toJson<int>(order),
    };
  }

  CategoryData copyWith(
          {int? id,
          String? name,
          String? color,
          Value<int?> icon = const Value.absent(),
          int? order}) =>
      CategoryData(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        icon: icon.present ? icon.value : this.icon,
        order: order ?? this.order,
      );
  CategoryData copyWithCompanion(CategoriesCompanion data) {
    return CategoryData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, icon, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryData &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.order == this.order);
}

class CategoriesCompanion extends UpdateCompanion<CategoryData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> color;
  final Value<int?> icon;
  final Value<int> order;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.order = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String color,
    this.icon = const Value.absent(),
    this.order = const Value.absent(),
  })  : name = Value(name),
        color = Value(color);
  static Insertable<CategoryData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? icon,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (order != null) 'order': order,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? color,
      Value<int?>? icon,
      Value<int>? order}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<int>(icon.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $PomodoroSessionsTable pomodoroSessions =
      $PomodoroSessionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [projects, tasks, pomodoroSessions, categories];
}

typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  Value<String> color,
  Value<int?> icon,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
  Value<int> order,
  Value<bool> isArchived,
  Value<String> viewMode,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<String> color,
  Value<int?> icon,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
  Value<int> order,
  Value<bool> isArchived,
  Value<String> viewMode,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, ProjectData> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<TaskData>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: $_aliasNameGenerator(db.projects.id, db.tasks.projectId));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get viewMode => $composableBuilder(
      column: $table.viewMode, builder: (column) => ColumnFilters(column));

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get viewMode => $composableBuilder(
      column: $table.viewMode, builder: (column) => ColumnOrderings(column));
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<String> get viewMode =>
      $composableBuilder(column: $table.viewMode, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    ProjectData,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (ProjectData, $$ProjectsTableReferences),
    ProjectData,
    PrefetchHooks Function({bool tasksRefs})> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<int?> icon = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<String> viewMode = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            name: name,
            description: description,
            color: color,
            icon: icon,
            createdAt: createdAt,
            archivedAt: archivedAt,
            order: order,
            isArchived: isArchived,
            viewMode: viewMode,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<int?> icon = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<String> viewMode = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            name: name,
            description: description,
            color: color,
            icon: icon,
            createdAt: createdAt,
            archivedAt: archivedAt,
            order: order,
            isArchived: isArchived,
            viewMode: viewMode,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<ProjectData, $ProjectsTable,
                            TaskData>(
                        currentTable: table,
                        referencedTable:
                            $$ProjectsTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0).tasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTable,
    ProjectData,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (ProjectData, $$ProjectsTableReferences),
    ProjectData,
    PrefetchHooks Function({bool tasksRefs})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  Value<int> priority,
  Value<int> status,
  Value<DateTime?> dueDate,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int?> projectId,
  Value<int?> duration,
  Value<bool> isRecurring,
  Value<String?> recurringPattern,
  Value<int?> parentId,
  Value<String?> labels,
  Value<int> order,
  Value<String?> voiceNote,
  Value<int?> estimatedMinutes,
  Value<int> spentMinutes,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<int> priority,
  Value<int> status,
  Value<DateTime?> dueDate,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int?> projectId,
  Value<int?> duration,
  Value<bool> isRecurring,
  Value<String?> recurringPattern,
  Value<int?> parentId,
  Value<String?> labels,
  Value<int> order,
  Value<String?> voiceNote,
  Value<int?> estimatedMinutes,
  Value<int> spentMinutes,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskData> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.tasks.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<int>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TasksTable _parentIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.tasks.parentId, db.tasks.id));

  $$TasksTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PomodoroSessionsTable, List<PomodoroSessionData>>
      _pomodoroSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.pomodoroSessions,
              aliasName: $_aliasNameGenerator(
                  db.tasks.id, db.pomodoroSessions.taskId));

  $$PomodoroSessionsTableProcessedTableManager get pomodoroSessionsRefs {
    final manager =
        $$PomodoroSessionsTableTableManager($_db, $_db.pomodoroSessions)
            .filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pomodoroSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurringPattern => $composableBuilder(
      column: $table.recurringPattern,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get labels => $composableBuilder(
      column: $table.labels, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voiceNote => $composableBuilder(
      column: $table.voiceNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get spentMinutes => $composableBuilder(
      column: $table.spentMinutes, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TasksTableFilterComposer get parentId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> pomodoroSessionsRefs(
      Expression<bool> Function($$PomodoroSessionsTableFilterComposer f) f) {
    final $$PomodoroSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pomodoroSessions,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PomodoroSessionsTableFilterComposer(
              $db: $db,
              $table: $db.pomodoroSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurringPattern => $composableBuilder(
      column: $table.recurringPattern,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get labels => $composableBuilder(
      column: $table.labels, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voiceNote => $composableBuilder(
      column: $table.voiceNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get spentMinutes => $composableBuilder(
      column: $table.spentMinutes,
      builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TasksTableOrderingComposer get parentId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get recurringPattern => $composableBuilder(
      column: $table.recurringPattern, builder: (column) => column);

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get voiceNote =>
      $composableBuilder(column: $table.voiceNote, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes, builder: (column) => column);

  GeneratedColumn<int> get spentMinutes => $composableBuilder(
      column: $table.spentMinutes, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TasksTableAnnotationComposer get parentId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> pomodoroSessionsRefs<T extends Object>(
      Expression<T> Function($$PomodoroSessionsTableAnnotationComposer a) f) {
    final $$PomodoroSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pomodoroSessions,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PomodoroSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.pomodoroSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskData,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskData, $$TasksTableReferences),
    TaskData,
    PrefetchHooks Function(
        {bool projectId, bool parentId, bool pomodoroSessionsRefs})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> projectId = const Value.absent(),
            Value<int?> duration = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurringPattern = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<String?> labels = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String?> voiceNote = const Value.absent(),
            Value<int?> estimatedMinutes = const Value.absent(),
            Value<int> spentMinutes = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            title: title,
            description: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            createdAt: createdAt,
            completedAt: completedAt,
            projectId: projectId,
            duration: duration,
            isRecurring: isRecurring,
            recurringPattern: recurringPattern,
            parentId: parentId,
            labels: labels,
            order: order,
            voiceNote: voiceNote,
            estimatedMinutes: estimatedMinutes,
            spentMinutes: spentMinutes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> projectId = const Value.absent(),
            Value<int?> duration = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurringPattern = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<String?> labels = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String?> voiceNote = const Value.absent(),
            Value<int?> estimatedMinutes = const Value.absent(),
            Value<int> spentMinutes = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            title: title,
            description: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            createdAt: createdAt,
            completedAt: completedAt,
            projectId: projectId,
            duration: duration,
            isRecurring: isRecurring,
            recurringPattern: recurringPattern,
            parentId: parentId,
            labels: labels,
            order: order,
            voiceNote: voiceNote,
            estimatedMinutes: estimatedMinutes,
            spentMinutes: spentMinutes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {projectId = false,
              parentId = false,
              pomodoroSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pomodoroSessionsRefs) db.pomodoroSessions
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable: $$TasksTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._projectIdTable(db).id,
                  ) as T;
                }
                if (parentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentId,
                    referencedTable: $$TasksTableReferences._parentIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._parentIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pomodoroSessionsRefs)
                    await $_getPrefetchedData<TaskData, $TasksTable,
                            PomodoroSessionData>(
                        currentTable: table,
                        referencedTable: $$TasksTableReferences
                            ._pomodoroSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .pomodoroSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskData,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskData, $$TasksTableReferences),
    TaskData,
    PrefetchHooks Function(
        {bool projectId, bool parentId, bool pomodoroSessionsRefs})>;
typedef $$PomodoroSessionsTableCreateCompanionBuilder
    = PomodoroSessionsCompanion Function({
  Value<int> id,
  required int taskId,
  required int duration,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  Value<bool> isCompleted,
  Value<String> type,
});
typedef $$PomodoroSessionsTableUpdateCompanionBuilder
    = PomodoroSessionsCompanion Function({
  Value<int> id,
  Value<int> taskId,
  Value<int> duration,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<bool> isCompleted,
  Value<String> type,
});

final class $$PomodoroSessionsTableReferences extends BaseReferences<
    _$AppDatabase, $PomodoroSessionsTable, PomodoroSessionData> {
  $$PomodoroSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
      $_aliasNameGenerator(db.pomodoroSessions.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PomodoroSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PomodoroSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PomodoroSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PomodoroSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PomodoroSessionsTable,
    PomodoroSessionData,
    $$PomodoroSessionsTableFilterComposer,
    $$PomodoroSessionsTableOrderingComposer,
    $$PomodoroSessionsTableAnnotationComposer,
    $$PomodoroSessionsTableCreateCompanionBuilder,
    $$PomodoroSessionsTableUpdateCompanionBuilder,
    (PomodoroSessionData, $$PomodoroSessionsTableReferences),
    PomodoroSessionData,
    PrefetchHooks Function({bool taskId})> {
  $$PomodoroSessionsTableTableManager(
      _$AppDatabase db, $PomodoroSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PomodoroSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PomodoroSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PomodoroSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> taskId = const Value.absent(),
            Value<int> duration = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String> type = const Value.absent(),
          }) =>
              PomodoroSessionsCompanion(
            id: id,
            taskId: taskId,
            duration: duration,
            startedAt: startedAt,
            completedAt: completedAt,
            isCompleted: isCompleted,
            type: type,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int taskId,
            required int duration,
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String> type = const Value.absent(),
          }) =>
              PomodoroSessionsCompanion.insert(
            id: id,
            taskId: taskId,
            duration: duration,
            startedAt: startedAt,
            completedAt: completedAt,
            isCompleted: isCompleted,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PomodoroSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$PomodoroSessionsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$PomodoroSessionsTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PomodoroSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PomodoroSessionsTable,
    PomodoroSessionData,
    $$PomodoroSessionsTableFilterComposer,
    $$PomodoroSessionsTableOrderingComposer,
    $$PomodoroSessionsTableAnnotationComposer,
    $$PomodoroSessionsTableCreateCompanionBuilder,
    $$PomodoroSessionsTableUpdateCompanionBuilder,
    (PomodoroSessionData, $$PomodoroSessionsTableReferences),
    PomodoroSessionData,
    PrefetchHooks Function({bool taskId})>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required String color,
  Value<int?> icon,
  Value<int> order,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> color,
  Value<int?> icon,
  Value<int> order,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryData,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (
      CategoryData,
      BaseReferences<_$AppDatabase, $CategoriesTable, CategoryData>
    ),
    CategoryData,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<int?> icon = const Value.absent(),
            Value<int> order = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            color: color,
            icon: icon,
            order: order,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String color,
            Value<int?> icon = const Value.absent(),
            Value<int> order = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            color: color,
            icon: icon,
            order: order,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryData,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (
      CategoryData,
      BaseReferences<_$AppDatabase, $CategoriesTable, CategoryData>
    ),
    CategoryData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$PomodoroSessionsTableTableManager get pomodoroSessions =>
      $$PomodoroSessionsTableTableManager(_db, _db.pomodoroSessions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
}
