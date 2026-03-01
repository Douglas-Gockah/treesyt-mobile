import 'models.dart';

/// Seeded mock forms — each form contains realistic agricultural survey
/// questions and collectively demonstrates every question type available
/// in the mobile renderer.
final List<FormModel> kMockForms = [
  // -------------------------------------------------------------------------
  // 1. Farming Best Practices
  // -------------------------------------------------------------------------
  FormModel(
    id: 'form-001',
    title: 'Farming Best Practices',
    description: 'General farming practices assessment.',
    status: 'live',
    submissions: 24,
    createdBy: 'Admin',
    createdAt: '2024-11-01',
    updatedAt: '2024-11-15',
    questions: _farmingBestPracticesQuestions,
  ),

  // -------------------------------------------------------------------------
  // 2. Sustainable Agriculture Techniques
  // -------------------------------------------------------------------------
  FormModel(
    id: 'form-002',
    title: 'Sustainable Agriculture Techniques',
    description: 'Assessment of sustainable farming methods.',
    status: 'live',
    submissions: 18,
    createdBy: 'Admin',
    createdAt: '2024-11-03',
    updatedAt: '2024-11-20',
    questions: _sustainableAgricultureQuestions,
  ),

  // -------------------------------------------------------------------------
  // 3. Organic Farming Methods
  // -------------------------------------------------------------------------
  FormModel(
    id: 'form-003',
    title: 'Organic Farming Methods',
    description: 'Organic farming evaluation form.',
    status: 'live',
    submissions: 31,
    createdBy: 'Admin',
    createdAt: '2024-11-05',
    updatedAt: '2024-11-22',
    questions: _organicFarmingQuestions,
  ),

  // -------------------------------------------------------------------------
  // 4. Crop Rotation Strategies
  // -------------------------------------------------------------------------
  FormModel(
    id: 'form-004',
    title: 'Crop Rotation Strategies',
    description: 'Crop rotation planning and assessment.',
    status: 'live',
    submissions: 9,
    createdBy: 'Admin',
    createdAt: '2024-11-08',
    updatedAt: '2024-11-25',
    questions: _cropRotationQuestions,
  ),

  // -------------------------------------------------------------------------
  // 5. Pest Management Solutions
  // -------------------------------------------------------------------------
  FormModel(
    id: 'form-005',
    title: 'Pest Management Solutions',
    description: 'Integrated pest management survey.',
    status: 'live',
    submissions: 14,
    createdBy: 'Admin',
    createdAt: '2024-11-10',
    updatedAt: '2024-11-28',
    questions: _pestManagementQuestions,
  ),

  // -------------------------------------------------------------------------
  // 6. Soil Health Improvement
  // -------------------------------------------------------------------------
  FormModel(
    id: 'form-006',
    title: 'Soil Health Improvement',
    description: 'Soil quality and improvement assessment.',
    status: 'live',
    submissions: 7,
    createdBy: 'Admin',
    createdAt: '2024-11-12',
    updatedAt: '2024-11-30',
    questions: _soilHealthQuestions,
  ),

  // -------------------------------------------------------------------------
  // 7. Water Conservation Practices
  //    Fully seeded — showcases every question renderer (19 types).
  // -------------------------------------------------------------------------
  FormModel(
    id: 'form-007',
    title: 'Water Conservation Practices',
    description: 'Survey on water usage and conservation strategies.',
    status: 'live',
    submissions: 42,
    createdBy: 'Admin',
    createdAt: '2024-11-14',
    updatedAt: '2024-12-01',
    questions: _waterConservationQuestions,
  ),

  // -------------------------------------------------------------------------
  // 8. Harvesting Techniques
  // -------------------------------------------------------------------------
  FormModel(
    id: 'form-008',
    title: 'Harvesting Techniques',
    description: 'Post-harvest handling and techniques assessment.',
    status: 'live',
    submissions: 5,
    createdBy: 'Admin',
    createdAt: '2024-11-18',
    updatedAt: '2024-12-03',
    questions: _harvestingTechniquesQuestions,
  ),

  // -------------------------------------------------------------------------
  // 9. Advanced Field Data Collection
  //    Showcases every new question type:
  //    ranking, likertScale, netPromoterScore, video, contactInfo, email,
  //    fileUpload, signature, currency, calculatedField
  //    (plus farmerName, autoId, location, barcode from previous set)
  // -------------------------------------------------------------------------
  FormModel(
    id: 'form-009',
    title: 'Advanced Field Data Collection',
    description: 'Full-feature survey demonstrating all question types.',
    status: 'live',
    submissions: 0,
    createdBy: 'Admin',
    createdAt: '2025-01-10',
    updatedAt: '2025-01-10',
    questions: _advancedFieldSurveyQuestions,
  ),
];

// ===========================================================================
// Form 001 — Farming Best Practices
// Types: autoId, farmerName, section, shortText, multipleChoice, checkbox,
//        number, decimal, yesNo, longText
// ===========================================================================
const List<Question> _farmingBestPracticesQuestions = [
  Question(
    id: 'fbp-01',
    type: QuestionType.autoId,
    question: 'Farm Record ID',
    required: false,
    order: 0,
    idPrefix: 'FRM',
    idLength: 10,
  ),
  Question(
    id: 'fbp-02',
    type: QuestionType.farmerName,
    question: 'Name of farmer as it appears on a valid national ID',
    required: true,
    order: 1,
  ),
  Question(
    id: 'fbp-03',
    type: QuestionType.section,
    question: 'Basic Farm Information',
    required: false,
    order: 2,
    sectionDescription: 'General details about the farm and farmer.',
  ),
  Question(
    id: 'fbp-04',
    type: QuestionType.shortText,
    question: 'Name of community / village where the farm is located',
    required: true,
    order: 3,
  ),
  Question(
    id: 'fbp-05',
    type: QuestionType.multipleChoice,
    question: 'What is your primary farming system?',
    required: true,
    order: 4,
    options: ['Subsistence', 'Semi-commercial', 'Commercial', 'Mixed'],
  ),
  Question(
    id: 'fbp-06',
    type: QuestionType.checkbox,
    question: 'Which crops do you currently grow? (Select all that apply)',
    required: true,
    order: 5,
    options: [
      'Maize',
      'Rice',
      'Cassava',
      'Yam',
      'Plantain',
      'Vegetables',
      'Groundnuts',
    ],
  ),
  Question(
    id: 'fbp-07',
    type: QuestionType.number,
    question: 'How many years have you been farming?',
    required: true,
    order: 6,
    minValue: 0,
    maxValue: 70,
  ),
  Question(
    id: 'fbp-08',
    type: QuestionType.decimal,
    question: 'Total farm size (in acres)',
    required: true,
    order: 7,
  ),
  Question(
    id: 'fbp-09',
    type: QuestionType.section,
    question: 'Farming Practices',
    required: false,
    order: 8,
    sectionDescription: 'Information about the practices currently in use.',
  ),
  Question(
    id: 'fbp-10',
    type: QuestionType.checkbox,
    question: 'Which best practices do you currently use?',
    required: false,
    order: 9,
    options: [
      'Crop rotation',
      'Mulching',
      'Composting',
      'Cover cropping',
      'Drip irrigation',
      'Agroforestry',
    ],
  ),
  Question(
    id: 'fbp-11',
    type: QuestionType.yesNo,
    question:
        'Have you received any formal farming training in the past 2 years?',
    required: true,
    order: 10,
  ),
  Question(
    id: 'fbp-12',
    type: QuestionType.longText,
    question: 'Describe the main farming challenges you currently face',
    required: false,
    order: 11,
  ),
];

// ===========================================================================
// Form 002 — Sustainable Agriculture Techniques
// Types: autoId, farmerName, shortText, section, multipleChoice, checkbox,
//        yesNo, rating, decimal, date, month, dayOfWeek, image, location,
//        number, longText
// ===========================================================================
const List<Question> _sustainableAgricultureQuestions = [
  Question(
    id: 'sat-01',
    type: QuestionType.autoId,
    question: 'Survey ID',
    required: false,
    order: 0,
    idPrefix: 'SAT',
    idLength: 10,
  ),
  Question(
    id: 'sat-02',
    type: QuestionType.farmerName,
    question: 'Name of farmer (as on national ID)',
    required: true,
    order: 1,
  ),
  Question(
    id: 'sat-03',
    type: QuestionType.shortText,
    question: 'District / Region',
    required: true,
    order: 2,
  ),
  Question(
    id: 'sat-04',
    type: QuestionType.section,
    question: 'Technique Adoption',
    required: false,
    order: 3,
    sectionDescription: 'Questions about sustainable techniques in use.',
  ),
  Question(
    id: 'sat-05',
    type: QuestionType.multipleChoice,
    question: 'Which sustainable technique do you primarily rely on?',
    required: true,
    order: 4,
    options: [
      'Agroforestry',
      'Conservation tillage',
      'Intercropping',
      'Organic farming',
      'Water harvesting',
    ],
  ),
  Question(
    id: 'sat-06',
    type: QuestionType.checkbox,
    question: 'Which inputs do you currently use?',
    required: false,
    order: 5,
    options: [
      'Compost',
      'Biochar',
      'Green manure',
      'Liquid fertiliser',
      'Neem extract',
      'Mineral fertiliser',
    ],
  ),
  Question(
    id: 'sat-07',
    type: QuestionType.yesNo,
    question:
        'Have you adopted any new sustainable technique in the last season?',
    required: true,
    order: 6,
  ),
  Question(
    id: 'sat-08',
    type: QuestionType.rating,
    question:
        'How would you rate the support you receive from extension officers?',
    required: false,
    order: 7,
    maxRating: 5,
  ),
  Question(
    id: 'sat-09',
    type: QuestionType.decimal,
    question: 'Farm area in hectares',
    required: true,
    order: 8,
  ),
  Question(
    id: 'sat-10',
    type: QuestionType.date,
    question: 'When did you last attend a training session?',
    required: false,
    order: 9,
  ),
  Question(
    id: 'sat-11',
    type: QuestionType.month,
    question: 'Which month is your main harvesting season?',
    required: false,
    order: 10,
    options: [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ],
  ),
  Question(
    id: 'sat-12',
    type: QuestionType.dayOfWeek,
    question: 'What is your preferred day for group meetings?',
    required: false,
    order: 11,
    options: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  ),
  Question(
    id: 'sat-13',
    type: QuestionType.image,
    question: 'Upload a photo of your current field',
    required: false,
    order: 12,
  ),
  Question(
    id: 'sat-14',
    type: QuestionType.location,
    question: 'GPS location of your farm',
    required: true,
    order: 13,
  ),
  Question(
    id: 'sat-15',
    type: QuestionType.longText,
    question:
        'What additional support would help you adopt more sustainable practices?',
    required: false,
    order: 14,
  ),
];

// ===========================================================================
// Form 003 — Organic Farming Methods
// Types: autoId, farmerName, section, multipleChoice, checkbox, yesNo,
//        number, decimal, date, image, longText
// ===========================================================================
const List<Question> _organicFarmingQuestions = [
  Question(
    id: 'org-01',
    type: QuestionType.autoId,
    question: 'Organic Survey ID',
    required: false,
    order: 0,
    idPrefix: 'ORG',
    idLength: 10,
  ),
  Question(
    id: 'org-02',
    type: QuestionType.farmerName,
    question: 'Name of farmer (as on national ID)',
    required: true,
    order: 1,
  ),
  Question(
    id: 'org-03',
    type: QuestionType.section,
    question: 'Certification & Practice',
    required: false,
    order: 2,
    sectionDescription: 'Details about organic certification and practices.',
  ),
  Question(
    id: 'org-04',
    type: QuestionType.multipleChoice,
    question: 'Current organic certification status',
    required: true,
    order: 3,
    options: [
      'Certified organic',
      'In transition (12–24 months)',
      'Not certified but practising organic',
      'Not organic',
    ],
  ),
  Question(
    id: 'org-05',
    type: QuestionType.checkbox,
    question: 'Which organic inputs do you use? (Select all that apply)',
    required: false,
    order: 4,
    options: [
      'Compost',
      'Vermicompost',
      'Neem spray',
      'Wood ash',
      'Bone meal',
      'Biofertiliser',
    ],
  ),
  Question(
    id: 'org-06',
    type: QuestionType.yesNo,
    question:
        'Do you keep written records of your organic farming practices?',
    required: true,
    order: 5,
  ),
  Question(
    id: 'org-07',
    type: QuestionType.number,
    question: 'How many seasons have you been farming organically?',
    required: true,
    order: 6,
    minValue: 0,
    maxValue: 50,
  ),
  Question(
    id: 'org-08',
    type: QuestionType.decimal,
    question: 'Average yield per acre this season (kg)',
    required: false,
    order: 7,
  ),
  Question(
    id: 'org-09',
    type: QuestionType.date,
    question: 'Date of your most recent soil health test',
    required: false,
    order: 8,
  ),
  Question(
    id: 'org-10',
    type: QuestionType.image,
    question: 'Take a photo of your organic inputs storage area',
    required: false,
    order: 9,
  ),
  Question(
    id: 'org-11',
    type: QuestionType.longText,
    question:
        'What are the main lessons you have learned from organic farming?',
    required: false,
    order: 10,
  ),
];

// ===========================================================================
// Form 004 — Crop Rotation Strategies
// Types: autoId, farmerName, multipleChoice, checkbox, number, decimal,
//        date, longText
// ===========================================================================
const List<Question> _cropRotationQuestions = [
  Question(
    id: 'crs-01',
    type: QuestionType.autoId,
    question: 'Rotation Survey ID',
    required: false,
    order: 0,
    idPrefix: 'CRS',
    idLength: 10,
  ),
  Question(
    id: 'crs-02',
    type: QuestionType.farmerName,
    question: 'Name of farmer (as on national ID)',
    required: true,
    order: 1,
  ),
  Question(
    id: 'crs-03',
    type: QuestionType.multipleChoice,
    question: 'Which crop rotation pattern do you primarily follow?',
    required: true,
    order: 2,
    options: [
      'Legume – Cereal',
      'Cereal – Root crop',
      'Three-crop rotation',
      'No fixed pattern',
    ],
  ),
  Question(
    id: 'crs-04',
    type: QuestionType.checkbox,
    question: 'Which crops are included in your rotation?',
    required: true,
    order: 3,
    options: [
      'Maize',
      'Cowpea',
      'Soybean',
      'Cassava',
      'Groundnut',
      'Sorghum',
      'Yam',
    ],
  ),
  Question(
    id: 'crs-05',
    type: QuestionType.number,
    question: 'How many rotation cycles do you complete per year?',
    required: true,
    order: 4,
    minValue: 1,
    maxValue: 4,
  ),
  Question(
    id: 'crs-06',
    type: QuestionType.decimal,
    question:
        'Estimated yield improvement since starting rotation (% increase)',
    required: false,
    order: 5,
  ),
  Question(
    id: 'crs-07',
    type: QuestionType.date,
    question: 'When did your current rotation cycle begin?',
    required: true,
    order: 6,
  ),
  Question(
    id: 'crs-08',
    type: QuestionType.longText,
    question:
        'Describe your crop rotation strategy and its impact on soil health',
    required: false,
    order: 7,
  ),
];

// ===========================================================================
// Form 005 — Pest Management Solutions
// Types: autoId, farmerName, section, multipleChoice, checkbox, yesNo,
//        number, decimal, date, dayOfWeek, image, longText
// ===========================================================================
const List<Question> _pestManagementQuestions = [
  Question(
    id: 'pms-01',
    type: QuestionType.autoId,
    question: 'Pest Survey ID',
    required: false,
    order: 0,
    idPrefix: 'PMS',
    idLength: 10,
  ),
  Question(
    id: 'pms-02',
    type: QuestionType.farmerName,
    question: 'Name of farmer (as on national ID)',
    required: true,
    order: 1,
  ),
  Question(
    id: 'pms-03',
    type: QuestionType.section,
    question: 'Pest Identification',
    required: false,
    order: 2,
    sectionDescription: 'Identify the primary pests affecting your crops.',
  ),
  Question(
    id: 'pms-04',
    type: QuestionType.multipleChoice,
    question: 'What is the primary pest currently affecting your farm?',
    required: true,
    order: 3,
    options: [
      'Fall armyworm',
      'Aphids',
      'Whitefly',
      'Thrips',
      'Stem borer',
      'Rodents',
      'Weevils',
    ],
  ),
  Question(
    id: 'pms-05',
    type: QuestionType.checkbox,
    question: 'Which pest control methods do you use?',
    required: true,
    order: 4,
    options: [
      'Chemical pesticides',
      'Biopesticides',
      'Pheromone traps',
      'Beneficial insects',
      'Hand picking',
      'Cultural control (e.g. crop rotation)',
    ],
  ),
  Question(
    id: 'pms-06',
    type: QuestionType.yesNo,
    question: 'Do you currently use any chemical pesticides?',
    required: true,
    order: 5,
  ),
  Question(
    id: 'pms-07',
    type: QuestionType.number,
    question: 'How many times did you spray this season?',
    required: true,
    order: 6,
    minValue: 0,
    maxValue: 30,
  ),
  Question(
    id: 'pms-08',
    type: QuestionType.decimal,
    question: 'How much did you spend on pest control this season (GHS)?',
    required: false,
    order: 7,
  ),
  Question(
    id: 'pms-09',
    type: QuestionType.date,
    question: 'Date of the most recent pest outbreak',
    required: false,
    order: 8,
  ),
  Question(
    id: 'pms-10',
    type: QuestionType.dayOfWeek,
    question: 'On which day of the week do you typically spray?',
    required: false,
    order: 9,
    options: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  ),
  Question(
    id: 'pms-11',
    type: QuestionType.image,
    question: 'Take a photo of the affected crop or pest',
    required: false,
    order: 10,
  ),
  Question(
    id: 'pms-12',
    type: QuestionType.longText,
    question:
        'Describe the effectiveness of your current pest management approach',
    required: false,
    order: 11,
  ),
];

// ===========================================================================
// Form 006 — Soil Health Improvement
// Types: autoId, farmerName, section, multipleChoice, yesNo, decimal,
//        checkbox, date, number, rating, longText
// ===========================================================================
const List<Question> _soilHealthQuestions = [
  Question(
    id: 'shl-01',
    type: QuestionType.autoId,
    question: 'Soil Survey ID',
    required: false,
    order: 0,
    idPrefix: 'SHL',
    idLength: 10,
  ),
  Question(
    id: 'shl-02',
    type: QuestionType.farmerName,
    question: 'Name of farmer (as on national ID)',
    required: true,
    order: 1,
  ),
  Question(
    id: 'shl-03',
    type: QuestionType.section,
    question: 'Soil Profile',
    required: false,
    order: 2,
    sectionDescription: 'Details about your soil type and current condition.',
  ),
  Question(
    id: 'shl-04',
    type: QuestionType.multipleChoice,
    question: 'What is the dominant soil type on your farm?',
    required: true,
    order: 3,
    options: [
      'Sandy loam',
      'Clay loam',
      'Sandy clay',
      'Silty loam',
      'Loamy sand',
    ],
  ),
  Question(
    id: 'shl-05',
    type: QuestionType.yesNo,
    question: 'Have you conducted a soil test in the past 12 months?',
    required: true,
    order: 4,
  ),
  Question(
    id: 'shl-06',
    type: QuestionType.decimal,
    question: 'Current measured soil pH of your main field',
    required: false,
    order: 5,
  ),
  Question(
    id: 'shl-07',
    type: QuestionType.checkbox,
    question: 'Which soil amendments have you applied?',
    required: false,
    order: 6,
    options: [
      'Agricultural lime',
      'Compost',
      'Gypsum',
      'Biochar',
      'Wood ash',
      'Green manure',
    ],
  ),
  Question(
    id: 'shl-08',
    type: QuestionType.date,
    question: 'When was your last soil amendment applied?',
    required: false,
    order: 7,
  ),
  Question(
    id: 'shl-09',
    type: QuestionType.number,
    question: 'How many compost pits or bins do you currently maintain?',
    required: false,
    order: 8,
    minValue: 0,
    maxValue: 20,
  ),
  Question(
    id: 'shl-10',
    type: QuestionType.rating,
    question: 'How would you rate your overall soil health this season?',
    required: false,
    order: 9,
    maxRating: 5,
  ),
  Question(
    id: 'shl-11',
    type: QuestionType.longText,
    question:
        'Describe any visible improvements you have noticed in your soil health',
    required: false,
    order: 10,
  ),
];

// ===========================================================================
// Form 007 — Water Conservation Practices
// All 19 question types showcased with water-themed questions.
// ===========================================================================
const List<Question> _waterConservationQuestions = [
  // 1. Section
  Question(
    id: 'wcq-01',
    type: QuestionType.section,
    question: 'Farmer Profile',
    required: false,
    order: 0,
    sectionDescription: 'Basic farmer and farm identification details.',
  ),

  // 2. Auto ID
  Question(
    id: 'wcq-02',
    type: QuestionType.autoId,
    question: 'Water Survey ID',
    required: false,
    order: 1,
    idPrefix: 'WCP',
    idLength: 10,
  ),

  // 3. Farmer name
  Question(
    id: 'wcq-03',
    type: QuestionType.farmerName,
    question: 'Name of farmer as it appears on a valid national ID',
    required: true,
    order: 2,
  ),

  // 4. Short text
  Question(
    id: 'wcq-04',
    type: QuestionType.shortText,
    question: 'Name of farming community',
    required: true,
    order: 3,
  ),

  // 5. Location
  Question(
    id: 'wcq-05',
    type: QuestionType.location,
    question: 'GPS location of the farm',
    required: true,
    order: 4,
  ),

  // 6. Section
  Question(
    id: 'wcq-06',
    type: QuestionType.section,
    question: 'Water Sources & Usage',
    required: false,
    order: 5,
    sectionDescription: 'Details about water sources and usage patterns.',
  ),

  // 7. Multiple choice
  Question(
    id: 'wcq-07',
    type: QuestionType.multipleChoice,
    question: 'What is your primary water source for farming?',
    required: true,
    order: 6,
    options: [
      'River / stream',
      'Borehole / well',
      'Rainwater harvesting',
      'Irrigation canal',
      'Pond / dam',
    ],
  ),

  // 8. Checkbox
  Question(
    id: 'wcq-08',
    type: QuestionType.checkbox,
    question: 'Which water storage methods do you use?',
    required: false,
    order: 7,
    options: [
      'Reservoirs',
      'Earthen ponds',
      'Polytank / plastic tanks',
      'Underground cisterns',
      'Sand dams',
    ],
  ),

  // 9. Yes / No
  Question(
    id: 'wcq-09',
    type: QuestionType.yesNo,
    question: 'Do you practise any form of rainwater harvesting?',
    required: true,
    order: 8,
  ),

  // 10. Decimal
  Question(
    id: 'wcq-10',
    type: QuestionType.decimal,
    question: 'Estimated total water used per week (litres)',
    required: false,
    order: 9,
  ),

  // 11. Number
  Question(
    id: 'wcq-11',
    type: QuestionType.number,
    question: 'How many irrigation events do you carry out per week?',
    required: true,
    order: 10,
    minValue: 0,
    maxValue: 21,
  ),

  // 12. Date
  Question(
    id: 'wcq-12',
    type: QuestionType.date,
    question: 'Date of your last water quality test',
    required: false,
    order: 11,
  ),

  // 13. Date & time
  Question(
    id: 'wcq-13',
    type: QuestionType.datetime,
    question: 'When was the last flood or drought event on your farm?',
    required: false,
    order: 12,
  ),

  // 14. Time
  Question(
    id: 'wcq-14',
    type: QuestionType.time,
    question: 'What time do you typically start your morning irrigation?',
    required: false,
    order: 13,
  ),

  // 15. Month
  Question(
    id: 'wcq-15',
    type: QuestionType.month,
    question: 'Which month do you experience the highest water demand?',
    required: false,
    order: 14,
    options: [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ],
  ),

  // 16. Day of week
  Question(
    id: 'wcq-16',
    type: QuestionType.dayOfWeek,
    question: 'Which day do you carry out your main water management tasks?',
    required: false,
    order: 15,
    options: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  ),

  // 17. Rating
  Question(
    id: 'wcq-17',
    type: QuestionType.rating,
    question:
        'How would you rate the adequacy of water supply on your farm?',
    required: false,
    order: 16,
    maxRating: 5,
  ),

  // 18. Image / Camera
  Question(
    id: 'wcq-18',
    type: QuestionType.image,
    question: 'Take a photo of your main water source or irrigation setup',
    required: true,
    order: 17,
  ),

  // 19. Audio
  Question(
    id: 'wcq-19',
    type: QuestionType.audio,
    question:
        'Record a brief voice note describing your biggest water challenge',
    required: false,
    order: 18,
  ),

  // 20. Barcode / QR
  Question(
    id: 'wcq-20',
    type: QuestionType.barcode,
    question: 'Scan the QR code on your water permit certificate',
    required: false,
    order: 19,
  ),

  // 21. Long text
  Question(
    id: 'wcq-21',
    type: QuestionType.longText,
    question:
        'Describe any additional comments or suggestions on water conservation in your community',
    required: false,
    order: 20,
  ),
];

// ===========================================================================
// Form 008 — Harvesting Techniques
// Types: autoId, farmerName, section, multipleChoice, checkbox, number,
//        date, time, image, barcode, longText
// ===========================================================================
const List<Question> _harvestingTechniquesQuestions = [
  Question(
    id: 'hvt-01',
    type: QuestionType.autoId,
    question: 'Harvest Survey ID',
    required: false,
    order: 0,
    idPrefix: 'HVT',
    idLength: 10,
  ),
  Question(
    id: 'hvt-02',
    type: QuestionType.farmerName,
    question: 'Name of farmer (as on national ID)',
    required: true,
    order: 1,
  ),
  Question(
    id: 'hvt-03',
    type: QuestionType.section,
    question: 'Harvest Method',
    required: false,
    order: 2,
    sectionDescription: 'Details about how crops are harvested.',
  ),
  Question(
    id: 'hvt-04',
    type: QuestionType.multipleChoice,
    question: 'What is your primary harvest method?',
    required: true,
    order: 3,
    options: [
      'Manual harvesting',
      'Machine harvesting',
      'Combined manual and machine',
      'Contract harvesting',
    ],
  ),
  Question(
    id: 'hvt-05',
    type: QuestionType.checkbox,
    question: 'Which post-harvest processes do you carry out?',
    required: true,
    order: 4,
    options: [
      'Sun drying',
      'Shelling / threshing',
      'Grading and sorting',
      'Packaging',
      'Cold storage',
      'Processing (milling etc.)',
    ],
  ),
  Question(
    id: 'hvt-06',
    type: QuestionType.number,
    question: 'Current storage capacity (in 50 kg bags)',
    required: false,
    order: 5,
    minValue: 0,
    maxValue: 5000,
  ),
  Question(
    id: 'hvt-07',
    type: QuestionType.date,
    question: 'Date of your most recent harvest',
    required: true,
    order: 6,
  ),
  Question(
    id: 'hvt-08',
    type: QuestionType.time,
    question: 'What time did harvesting begin on that day?',
    required: false,
    order: 7,
  ),
  Question(
    id: 'hvt-09',
    type: QuestionType.image,
    question: 'Take a photo of your harvested produce or storage facility',
    required: false,
    order: 8,
  ),
  Question(
    id: 'hvt-10',
    type: QuestionType.barcode,
    question: 'Scan the warehouse receipt or produce tag barcode',
    required: false,
    order: 9,
  ),
  Question(
    id: 'hvt-11',
    type: QuestionType.longText,
    question: 'What are the main post-harvest challenges you face?',
    required: false,
    order: 10,
  ),
];

// ===========================================================================
// Form 009 — Advanced Field Data Collection
// Types: autoId, farmerName, section, contactInfo, email, location, barcode,
//        ranking, likertScale, netPromoterScore, rating, currency,
//        calculatedField, fileUpload, video, signature
// ===========================================================================
const List<Question> _advancedFieldSurveyQuestions = [
  // --- Identity ---
  Question(
    id: 'afs-01',
    type: QuestionType.autoId,
    question: 'Survey Record ID',
    required: false,
    order: 0,
    idPrefix: 'AFS',
    idLength: 10,
  ),
  Question(
    id: 'afs-02',
    type: QuestionType.farmerName,
    question: 'Farmer name (as on national ID)',
    required: true,
    order: 1,
  ),

  // --- Section: Contact & Identity ---
  Question(
    id: 'afs-03',
    type: QuestionType.section,
    question: 'Contact & Identity',
    required: false,
    order: 2,
    sectionDescription: 'Provide accurate contact details for follow-up visits.',
  ),
  Question(
    id: 'afs-04',
    type: QuestionType.contactInfo,
    question: 'Primary contact information',
    required: true,
    order: 3,
  ),
  Question(
    id: 'afs-05',
    type: QuestionType.email,
    question: 'Email address for digital receipts and updates',
    required: false,
    order: 4,
  ),
  Question(
    id: 'afs-06',
    type: QuestionType.location,
    question: 'GPS coordinates of the main farm plot',
    required: true,
    order: 5,
  ),
  Question(
    id: 'afs-07',
    type: QuestionType.barcode,
    question: 'Scan the farmer registration card barcode',
    required: false,
    order: 6,
  ),

  // --- Section: Priorities & Satisfaction ---
  Question(
    id: 'afs-08',
    type: QuestionType.section,
    question: 'Priorities & Satisfaction',
    required: false,
    order: 7,
    sectionDescription: 'Help us understand your biggest challenges and experience.',
  ),
  Question(
    id: 'afs-09',
    type: QuestionType.ranking,
    question: 'Rank your top farming challenges from most to least critical',
    required: true,
    order: 8,
    options: [
      'Access to credit / finance',
      'Soil fertility decline',
      'Unreliable rainfall',
      'Pest and disease outbreaks',
      'Poor access to markets',
      'High cost of inputs',
    ],
  ),
  Question(
    id: 'afs-10',
    type: QuestionType.likertScale,
    question: 'How satisfied are you with the support provided by the extension officer?',
    required: true,
    order: 9,
  ),
  Question(
    id: 'afs-11',
    type: QuestionType.netPromoterScore,
    question: 'How likely are you to recommend the TreeSyt programme to another farmer?',
    required: true,
    order: 10,
  ),
  Question(
    id: 'afs-12',
    type: QuestionType.rating,
    question: 'Rate the quality of training materials you have received (1 = Poor, 5 = Excellent)',
    required: false,
    order: 11,
    maxRating: 5,
  ),

  // --- Section: Financial Data ---
  Question(
    id: 'afs-13',
    type: QuestionType.section,
    question: 'Financial Data',
    required: false,
    order: 12,
    sectionDescription: 'Market values are used only for programme reporting.',
  ),
  Question(
    id: 'afs-14',
    type: QuestionType.currency,
    question: 'Market value of last season\'s total harvest (GHS)',
    required: true,
    order: 13,
    currencySymbol: 'GHS',
  ),
  Question(
    id: 'afs-15',
    type: QuestionType.number,
    question: 'Total input costs incurred last season (GHS)',
    required: false,
    order: 14,
    minValue: 0,
  ),
  Question(
    id: 'afs-16',
    type: QuestionType.calculatedField,
    question: 'Estimated net profit from last season',
    required: false,
    order: 15,
    calculatedFormula: 'Harvest value − Input costs',
  ),

  // --- Section: Media & Documentation ---
  Question(
    id: 'afs-17',
    type: QuestionType.section,
    question: 'Media & Documentation',
    required: false,
    order: 16,
    sectionDescription: 'Attach supporting documents and media evidence.',
  ),
  Question(
    id: 'afs-18',
    type: QuestionType.video,
    question: 'Record a short (≤ 2 min) video walkthrough of the farm',
    required: false,
    order: 17,
  ),
  Question(
    id: 'afs-19',
    type: QuestionType.fileUpload,
    question: 'Upload the most recent soil test laboratory report',
    required: false,
    order: 18,
  ),

  // --- Section: Confirmation ---
  Question(
    id: 'afs-20',
    type: QuestionType.section,
    question: 'Confirmation & Sign-off',
    required: false,
    order: 19,
    sectionDescription: 'Both farmer and agent must sign to validate this submission.',
  ),
  Question(
    id: 'afs-21',
    type: QuestionType.signature,
    question: 'Farmer\'s signature',
    required: true,
    order: 20,
  ),
  Question(
    id: 'afs-22',
    type: QuestionType.signature,
    question: 'Field agent\'s countersignature',
    required: true,
    order: 21,
  ),
];
