/// All data models for the TreeSyt mobile app.
///
/// These mirror the web app's TypeScript types (app/page.tsx) and extend
/// them with additional field types seen only in the mobile UI designs.

// ---------------------------------------------------------------------------
// Question type enum
// ---------------------------------------------------------------------------

enum QuestionType {
  // Text
  shortText,
  longText,

  // Numeric
  number,
  decimal,

  // Choice
  multipleChoice,
  checkbox,
  yesNo,

  // Date / time
  date,
  datetime,
  time,
  month,
  dayOfWeek,

  // Media / hardware
  image,
  audio,
  location,
  barcode,

  // Special
  autoId,
  farmerName,

  // Rating
  rating,

  // Ranking / scale
  ranking,
  likertScale,
  netPromoterScore,

  // Media
  video,

  // Contact
  contactInfo,
  email,

  // Upload / capture
  fileUpload,
  signature,

  // Finance
  currency,

  // Computed
  calculatedField,

  // Layout
  section,
}

extension QuestionTypeX on QuestionType {
  String get label {
    switch (this) {
      case QuestionType.shortText:    return 'Short text';
      case QuestionType.longText:     return 'Long text';
      case QuestionType.number:       return 'Number';
      case QuestionType.decimal:      return 'Decimal';
      case QuestionType.multipleChoice: return 'Multiple choice';
      case QuestionType.checkbox:     return 'Checkbox';
      case QuestionType.yesNo:        return 'Yes / No';
      case QuestionType.date:         return 'Date';
      case QuestionType.datetime:     return 'Date & time';
      case QuestionType.time:         return 'Time';
      case QuestionType.month:        return 'Month';
      case QuestionType.dayOfWeek:    return 'Day of week';
      case QuestionType.image:        return 'Image / Camera';
      case QuestionType.audio:        return 'Audio';
      case QuestionType.location:     return 'Location';
      case QuestionType.barcode:      return 'Barcode / QR';
      case QuestionType.autoId:       return 'Auto ID';
      case QuestionType.farmerName:   return 'Farmer name';
      case QuestionType.rating:            return 'Rating';
      case QuestionType.ranking:           return 'Ranking';
      case QuestionType.likertScale:       return 'Likert Scale';
      case QuestionType.netPromoterScore:  return 'Net Promoter Score';
      case QuestionType.video:             return 'Video';
      case QuestionType.contactInfo:       return 'Contact Info';
      case QuestionType.email:             return 'Email';
      case QuestionType.fileUpload:        return 'File Upload';
      case QuestionType.signature:         return 'Signature';
      case QuestionType.currency:          return 'Currency';
      case QuestionType.calculatedField:   return 'Calculated Field';
      case QuestionType.section:           return 'Section';
    }
  }

  /// Convert from the JSON string used in the web app / API.
  static QuestionType fromString(String s) {
    switch (s) {
      case 'short-text':       return QuestionType.shortText;
      case 'long-text':        return QuestionType.longText;
      case 'number':           return QuestionType.number;
      case 'decimal':          return QuestionType.decimal;
      case 'multiple-choice':  return QuestionType.multipleChoice;
      case 'checkbox':         return QuestionType.checkbox;
      case 'yes-no':           return QuestionType.yesNo;
      case 'date':             return QuestionType.date;
      case 'datetime':         return QuestionType.datetime;
      case 'time':             return QuestionType.time;
      case 'month':            return QuestionType.month;
      case 'day-of-week':      return QuestionType.dayOfWeek;
      case 'image':            return QuestionType.image;
      case 'audio':            return QuestionType.audio;
      case 'location':         return QuestionType.location;
      case 'barcode':          return QuestionType.barcode;
      case 'auto-id':          return QuestionType.autoId;
      case 'farmer-name':      return QuestionType.farmerName;
      case 'rating':             return QuestionType.rating;
      case 'ranking':            return QuestionType.ranking;
      case 'likert-scale':       return QuestionType.likertScale;
      case 'net-promoter-score': return QuestionType.netPromoterScore;
      case 'video':              return QuestionType.video;
      case 'contact-info':       return QuestionType.contactInfo;
      case 'email':              return QuestionType.email;
      case 'file-upload':        return QuestionType.fileUpload;
      case 'signature':          return QuestionType.signature;
      case 'currency':           return QuestionType.currency;
      case 'calculated-field':   return QuestionType.calculatedField;
      case 'section':            return QuestionType.section;
      default:                   return QuestionType.shortText;
    }
  }

  String toJsonString() {
    switch (this) {
      case QuestionType.shortText:      return 'short-text';
      case QuestionType.longText:       return 'long-text';
      case QuestionType.number:         return 'number';
      case QuestionType.decimal:        return 'decimal';
      case QuestionType.multipleChoice: return 'multiple-choice';
      case QuestionType.checkbox:       return 'checkbox';
      case QuestionType.yesNo:          return 'yes-no';
      case QuestionType.date:           return 'date';
      case QuestionType.datetime:       return 'datetime';
      case QuestionType.time:           return 'time';
      case QuestionType.month:          return 'month';
      case QuestionType.dayOfWeek:      return 'day-of-week';
      case QuestionType.image:          return 'image';
      case QuestionType.audio:          return 'audio';
      case QuestionType.location:       return 'location';
      case QuestionType.barcode:        return 'barcode';
      case QuestionType.autoId:         return 'auto-id';
      case QuestionType.farmerName:     return 'farmer-name';
      case QuestionType.rating:            return 'rating';
      case QuestionType.ranking:           return 'ranking';
      case QuestionType.likertScale:       return 'likert-scale';
      case QuestionType.netPromoterScore:  return 'net-promoter-score';
      case QuestionType.video:             return 'video';
      case QuestionType.contactInfo:       return 'contact-info';
      case QuestionType.email:             return 'email';
      case QuestionType.fileUpload:        return 'file-upload';
      case QuestionType.signature:         return 'signature';
      case QuestionType.currency:          return 'currency';
      case QuestionType.calculatedField:   return 'calculated-field';
      case QuestionType.section:           return 'section';
    }
  }
}

// ---------------------------------------------------------------------------
// Question model
// ---------------------------------------------------------------------------

class Question {
  final String id;
  final QuestionType type;
  final String question;
  final bool required;
  final int order;
  final List<String> options;         // for choice-based types
  final String? sectionDescription;   // for section type
  final String? idPrefix;             // for auto-id
  final int idLength;                  // for auto-id
  final int? minValue;
  final int? maxValue;
  final int maxRating;                // for rating type (default 5)
  final String? currencySymbol;       // for currency type (e.g. 'GHS', 'USD')
  final String? calculatedFormula;    // for calculated-field display

  const Question({
    required this.id,
    required this.type,
    required this.question,
    this.required = false,
    required this.order,
    this.options = const [],
    this.sectionDescription,
    this.idPrefix,
    this.idLength = 12,
    this.minValue,
    this.maxValue,
    this.maxRating = 5,
    this.currencySymbol,
    this.calculatedFormula,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      type: QuestionTypeX.fromString(json['type'] as String),
      question: json['question'] as String,
      required: json['required'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sectionDescription: json['sectionDescription'] as String?,
      idPrefix: json['idPrefix'] as String?,
      idLength: json['idLength'] as int? ?? 12,
      minValue: json['minValue'] as int?,
      maxValue: json['maxValue'] as int?,
      maxRating: json['maxRating'] as int? ?? 5,
      currencySymbol: json['currencySymbol'] as String?,
      calculatedFormula: json['calculatedFormula'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJsonString(),
        'question': question,
        'required': required,
        'order': order,
        'options': options,
        if (sectionDescription != null)
          'sectionDescription': sectionDescription,
        if (idPrefix != null) 'idPrefix': idPrefix,
        'idLength': idLength,
        if (minValue != null) 'minValue': minValue,
        if (maxValue != null) 'maxValue': maxValue,
        'maxRating': maxRating,
        if (currencySymbol != null) 'currencySymbol': currencySymbol,
        if (calculatedFormula != null) 'calculatedFormula': calculatedFormula,
      };
}

// ---------------------------------------------------------------------------
// Form model
// ---------------------------------------------------------------------------

class FormModel {
  final String id;
  final String title;
  final String description;
  final String status; // 'draft' | 'live'
  final int submissions;
  final String createdBy;
  final String createdAt;
  final String updatedAt;
  final List<Question> questions;

  const FormModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.submissions,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.questions,
  });

  int get questionCount => questions.length;

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      submissions: json['submissions'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status,
        'submissions': submissions,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

// ---------------------------------------------------------------------------
// Survey response (offline-first)
// ---------------------------------------------------------------------------

class SurveyResponse {
  final String id;
  final String formId;
  final String formTitle;
  final DateTime savedAt;
  final bool synced;
  /// Map of questionId → answer value (String, List<String>, or special types
  /// serialised as String for simplicity).
  final Map<String, dynamic> answers;

  const SurveyResponse({
    required this.id,
    required this.formId,
    required this.formTitle,
    required this.savedAt,
    required this.synced,
    required this.answers,
  });

  SurveyResponse copyWith({bool? synced}) => SurveyResponse(
        id: id,
        formId: formId,
        formTitle: formTitle,
        savedAt: savedAt,
        synced: synced ?? this.synced,
        answers: answers,
      );

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      id: json['id'] as String,
      formId: json['formId'] as String,
      formTitle: json['formTitle'] as String? ?? '',
      savedAt: DateTime.parse(json['savedAt'] as String),
      synced: json['synced'] as bool? ?? false,
      answers: Map<String, dynamic>.from(json['answers'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'formId': formId,
        'formTitle': formTitle,
        'savedAt': savedAt.toIso8601String(),
        'synced': synced,
        'answers': answers,
      };
}
