import '../../domain/entities/baseline_question_entity.dart';

const List<BaselineQuestionEntity> kBaselineQuestions = [
  // ── FOCUS (Q1–Q6) ────────────────────────────────────────────────────────

  BaselineQuestionEntity(
    id: 1,
    question:
        "You're in a competition and you've just scored your two worst shots consecutively. Your next move is to:",
    category: 'focus',
    options: [
      AnswerOptionEntity(text: 'Think about the impact on your total score', score: 1),
      AnswerOptionEntity(text: 'Your concentration breaks and you struggle to recover', score: 2),
      AnswerOptionEntity(text: 'Feel frustrated but push through the next shot', score: 3),
      AnswerOptionEntity(text: 'Immediately analyze what went wrong technically', score: 4),
      AnswerOptionEntity(text: 'Take a deliberate reset breath and return to your routine', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 2,
    question: 'During a 60-shot series, your concentration typically:',
    category: 'focus',
    options: [
      AnswerOptionEntity(text: 'Is generally poor with only occasional moments of clarity', score: 1),
      AnswerOptionEntity(text: 'Fluctuates unpredictably throughout', score: 2),
      AnswerOptionEntity(text: 'Is strong at the start and gradually fades', score: 3),
      AnswerOptionEntity(text: 'Builds up slowly and peaks in the middle', score: 4),
      AnswerOptionEntity(text: 'Stays consistent throughout the entire series', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 3,
    question: 'External noise or movement nearby during a critical shot:',
    category: 'focus',
    options: [
      AnswerOptionEntity(text: 'Significantly disrupts your aim and triggers a false shot', score: 1),
      AnswerOptionEntity(text: 'Often forces you to abort and restart your preparation', score: 2),
      AnswerOptionEntity(text: 'Is noticeable but you recover within the same shot', score: 3),
      AnswerOptionEntity(text: 'Causes slight hesitation but you manage to complete the shot', score: 4),
      AnswerOptionEntity(text: 'Barely registers — you\'re fully absorbed in your routine', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 4,
    question: 'In training, your coach gives you a technical correction mid-series. You:',
    category: 'focus',
    options: [
      AnswerOptionEntity(text: 'Find it hard to continue; the correction stays in your head', score: 1),
      AnswerOptionEntity(text: 'Struggle to maintain focus while processing the instruction', score: 2),
      AnswerOptionEntity(text: 'Note it but feel your flow disrupted for the next 2–3 shots', score: 3),
      AnswerOptionEntity(text: 'Acknowledge it but apply it only after completing the series', score: 4),
      AnswerOptionEntity(text: 'Immediately integrate it without losing your rhythm', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 5,
    question: 'Before a major competition, your mind is typically:',
    category: 'focus',
    options: [
      AnswerOptionEntity(text: 'Overwhelmed with worry and negative self-talk', score: 1),
      AnswerOptionEntity(text: 'Frequently drifting to scores, rankings, or expectations', score: 2),
      AnswerOptionEntity(text: 'Busy with performance scenarios and possible outcomes', score: 3),
      AnswerOptionEntity(text: 'Focused but with occasional distracting thoughts', score: 4),
      AnswerOptionEntity(text: 'Clear and locked onto your pre-performance routine', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 6,
    question: 'When you are in the middle of a good performance, you:',
    category: 'focus',
    options: [
      AnswerOptionEntity(text: 'Begin calculating scores, breaking your concentration', score: 1),
      AnswerOptionEntity(text: 'Start thinking "I need to keep this up" and tighten up', score: 2),
      AnswerOptionEntity(text: 'Become slightly aware of the good run and feel pressure', score: 3),
      AnswerOptionEntity(text: 'Consciously tell yourself to stay focused on the process', score: 4),
      AnswerOptionEntity(text: 'Stay in the moment and trust your process', score: 5),
    ],
  ),

  // ── EMOTIONAL STABILITY (Q7–Q12) ─────────────────────────────────────────

  BaselineQuestionEntity(
    id: 7,
    question: 'After a disappointing competition result, you typically:',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(text: 'Feel demotivated for weeks and question your ability', score: 1),
      AnswerOptionEntity(text: 'Remain affected for a week, reducing training quality', score: 2),
      AnswerOptionEntity(text: 'Feel down for 1–2 days but then bounce back', score: 3),
      AnswerOptionEntity(text: 'Recover within a few hours and refocus on training', score: 4),
      AnswerOptionEntity(text: 'Analyze calmly, identify lessons, and adjust your plan', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 8,
    question: 'If a teammate outperforms you significantly in a competition, you feel:',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(text: 'Distracted from your own game, affecting your scores', score: 1),
      AnswerOptionEntity(text: 'Anxious and compare yourself throughout the event', score: 2),
      AnswerOptionEntity(text: 'Slightly envious but ultimately inspired', score: 3),
      AnswerOptionEntity(text: 'Neutrally competitive — motivated to work harder', score: 4),
      AnswerOptionEntity(text: 'Proud of them with no effect on your own focus', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 9,
    question: 'When a well-prepared performance is disrupted by equipment issues, you:',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(text: 'Allow it to significantly alter your mental game', score: 1),
      AnswerOptionEntity(text: 'Take considerable time to regain your mental composure', score: 2),
      AnswerOptionEntity(text: 'Feel frustrated initially but reset within 5 minutes', score: 3),
      AnswerOptionEntity(text: 'Stay calm, manage the delay, and refocus effectively', score: 4),
      AnswerOptionEntity(text: 'Use the extra time for productive mental preparation', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 10,
    question: 'After scoring a personal best, your next training session tends to be:',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(text: 'Filled with pressure to repeat or surpass the performance', score: 1),
      AnswerOptionEntity(text: 'Relaxed to the point of reduced effort or focus', score: 2),
      AnswerOptionEntity(text: 'Slightly overconfident, causing technical lapses', score: 3),
      AnswerOptionEntity(text: 'Approached normally — you treat every session equally', score: 4),
      AnswerOptionEntity(text: 'Performed with heightened confidence and consistency', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 11,
    question: 'When your coach criticizes your technique or mental approach, you:',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(text: 'Take it personally and experience a drop in motivation', score: 1),
      AnswerOptionEntity(text: 'Feel defensive and find it hard to apply the feedback', score: 2),
      AnswerOptionEntity(text: 'Understand it intellectually but feel emotionally affected', score: 3),
      AnswerOptionEntity(text: 'Accept it professionally and use it immediately', score: 4),
      AnswerOptionEntity(text: 'Welcome it as valuable information for your improvement', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 12,
    question:
        'On a match day where conditions are difficult (weather, crowd, pressure), your emotional state is:',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(text: 'Completely destabilized — this is your biggest challenge', score: 1),
      AnswerOptionEntity(text: 'Significantly affected — your performance drops noticeably', score: 2),
      AnswerOptionEntity(text: 'Somewhat shaken but manageable with effort', score: 3),
      AnswerOptionEntity(text: 'Adaptable — you adjust quickly to the environment', score: 4),
      AnswerOptionEntity(text: 'Stable and focused — external conditions don\'t control you', score: 5),
    ],
  ),

  // ── DECISION STYLE (Q13–Q18) ──────────────────────────────────────────────

  BaselineQuestionEntity(
    id: 13,
    question: 'Before executing a shot, your pre-shot routine:',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(text: 'Does not exist — you approach each shot instinctively', score: 1),
      AnswerOptionEntity(text: 'Varies significantly depending on your mood or results', score: 2),
      AnswerOptionEntity(text: 'Is sometimes skipped when you feel rushed or anxious', score: 3),
      AnswerOptionEntity(text: 'Is partially completed under high pressure', score: 4),
      AnswerOptionEntity(text: 'Is consistently followed regardless of score or pressure', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 14,
    question: 'When your performance strategy is not working in a competition, you:',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(text: 'Panic and try different things without a clear rationale', score: 1),
      AnswerOptionEntity(text: 'Make multiple changes simultaneously, losing consistency', score: 2),
      AnswerOptionEntity(text: 'Stick to the plan even if it\'s clearly not working', score: 3),
      AnswerOptionEntity(text: 'Consult your coach or mental notes for a reset cue', score: 4),
      AnswerOptionEntity(text: 'Calmly identify one variable and adjust it systematically', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 15,
    question: 'Under competition pressure, the quality of your decision-making:',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(text: 'Breaks down completely in high-stakes situations', score: 1),
      AnswerOptionEntity(text: 'Noticeably deteriorates under pressure', score: 2),
      AnswerOptionEntity(text: 'Is somewhat reduced but remains functional', score: 3),
      AnswerOptionEntity(text: 'Remains consistent with your training performance', score: 4),
      AnswerOptionEntity(text: 'Slightly improves — pressure activates your focus', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 16,
    question: 'After a bad shot, how long does it take you to fully reset?',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(text: 'It affects the rest of the series', score: 1),
      AnswerOptionEntity(text: 'Several shots — the mistake stays with you', score: 2),
      AnswerOptionEntity(text: 'Within the next 2–3 shots', score: 3),
      AnswerOptionEntity(text: 'By the start of your next shot\'s routine', score: 4),
      AnswerOptionEntity(text: 'Immediately — you have a reliable reset cue', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 17,
    question: 'In training, you respond to a coach\'s tactical instruction by:',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(text: 'Struggling to integrate new information mid-session', score: 2),
      AnswerOptionEntity(text: 'Asking for clarification multiple times before applying', score: 2),
      AnswerOptionEntity(text: 'Applying it inconsistently — cognitive load is high', score: 3),
      AnswerOptionEntity(text: 'Understanding it but needing a practice rep first', score: 4),
      AnswerOptionEntity(text: 'Immediately processing and applying it accurately', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 18,
    question:
        'You are 3 shots from the end, and the score is extremely close. You:',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(text: 'Lose technical control as your mind races ahead', score: 1),
      AnswerOptionEntity(text: 'Rush through the shots to reduce the pressure', score: 2),
      AnswerOptionEntity(text: 'Become overly cautious — your shots become tentative', score: 3),
      AnswerOptionEntity(text: 'Feel the pressure but stay process-focused', score: 4),
      AnswerOptionEntity(text: 'Rely on your routine, one shot at a time, no score awareness', score: 5),
    ],
  ),

  // ── MOTIVATION (Q19–Q25) ──────────────────────────────────────────────────

  BaselineQuestionEntity(
    id: 19,
    question: 'What primarily drives you to train daily?',
    category: 'motivation',
    options: [
      AnswerOptionEntity(text: 'Habit or obligation — you\'re not sure why anymore', score: 1),
      AnswerOptionEntity(text: 'Pressure from family, coach, or peers', score: 2),
      AnswerOptionEntity(text: 'The excitement of competition and winning', score: 3),
      AnswerOptionEntity(text: 'The desire to represent your country or institution', score: 4),
      AnswerOptionEntity(text: 'Genuine love for the sport and the pursuit of mastery', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 20,
    question: 'When training feels repetitive and unrewarding, you:',
    category: 'motivation',
    options: [
      AnswerOptionEntity(text: 'Skip the session or significantly reduce duration', score: 1),
      AnswerOptionEntity(text: 'Reduce the quality of your effort to get through it', score: 2),
      AnswerOptionEntity(text: 'Talk to your coach to regain perspective and motivation', score: 3),
      AnswerOptionEntity(text: 'Push through with full intensity and commitment', score: 4),
      AnswerOptionEntity(text: 'Find creative ways to make it challenging and meaningful', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 21,
    question: 'You have just missed selection for an important competition. You:',
    category: 'motivation',
    options: [
      AnswerOptionEntity(text: 'Question whether you belong in the sport', score: 1),
      AnswerOptionEntity(text: 'Continue training mechanically, but motivation is low', score: 2),
      AnswerOptionEntity(text: 'Feel demotivated for weeks, impacting your training', score: 2),
      AnswerOptionEntity(text: 'Use it as direct fuel to train harder and smarter', score: 4),
      AnswerOptionEntity(text: 'Experience brief disappointment, then refocus with a clear goal', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 22,
    question: 'Your relationship with your performance goals can best be described as:',
    category: 'motivation',
    options: [
      AnswerOptionEntity(text: 'Non-existent — you train without specific targets', score: 1),
      AnswerOptionEntity(text: 'Dependent on others\' expectations', score: 2),
      AnswerOptionEntity(text: 'Vague — you have a general desire to improve', score: 3),
      AnswerOptionEntity(text: 'Present in your mind but not formally defined', score: 4),
      AnswerOptionEntity(text: 'Clear, written, and revisited regularly with purpose', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 23,
    question: 'When facing a multi-month performance plateau, your response is to:',
    category: 'motivation',
    options: [
      AnswerOptionEntity(text: 'Seriously consider reducing or stopping training', score: 1),
      AnswerOptionEntity(text: 'Wait passively for the plateau to pass on its own', score: 2),
      AnswerOptionEntity(text: 'Increase volume of training hoping to break through', score: 3),
      AnswerOptionEntity(text: 'Seek external help — coach, sports psychologist, etc.', score: 4),
      AnswerOptionEntity(text: 'Systematically analyze contributing factors and adapt', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 24,
    question: 'How important is psychological training to your overall preparation?',
    category: 'motivation',
    options: [
      AnswerOptionEntity(text: 'I believe mental strength is fixed and cannot be trained', score: 1),
      AnswerOptionEntity(text: 'Not a priority — technique is what matters most', score: 2),
      AnswerOptionEntity(text: 'Somewhat important — I focus mainly on technical drills', score: 3),
      AnswerOptionEntity(text: 'Very important — I\'d like to do more but lack structure', score: 4),
      AnswerOptionEntity(text: 'It\'s a core part of my weekly routine', score: 5),
    ],
  ),

  BaselineQuestionEntity(
    id: 25,
    question: 'Looking ahead to the next 12 months, you feel:',
    category: 'motivation',
    options: [
      AnswerOptionEntity(text: 'Uncertain whether to continue in the sport at this level', score: 1),
      AnswerOptionEntity(text: 'Anxious about performance expectations and outcomes', score: 2),
      AnswerOptionEntity(text: 'Neutral — you\'ll train and see what happens', score: 3),
      AnswerOptionEntity(text: 'Optimistic but uncertain about how to achieve your goals', score: 4),
      AnswerOptionEntity(text: 'Excited and clear — you have a defined path to improve', score: 5),
    ],
  ),
];
