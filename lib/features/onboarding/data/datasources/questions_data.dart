import '../../domain/entities/baseline_question_entity.dart';

const List<BaselineQuestionEntity> kBaselineQuestions = [
  // ── FOCUS (Q1, Q4, Q5, Q11, Q13, Q15, Q24) ───────────────────────────────

  BaselineQuestionEntity(
    id: 1,
    question:
        'You are entering the final series and notice your pulse is racing. How do you manage your heart rate?',
    category: 'focus',
    options: [
      AnswerOptionEntity(
          text: 'Take a deep rhythmic breath and reset my trigger finger focus.',
          score: 4),
      AnswerOptionEntity(
          text: 'Tell myself to stay calm and try to ignore the heartbeat.',
          score: 3),
      AnswerOptionEntity(
          text: 'Speed up my shots to get the series over with quickly.',
          score: 2),
      AnswerOptionEntity(
          text: 'Panic and worry that the shaking will cause a poor shot.',
          score: 1),
    ],
  ),

  // ── EMOTIONAL STABILITY (Q2, Q9, Q16, Q17, Q18, Q19, Q21, Q22, Q23) ──────

  BaselineQuestionEntity(
    id: 2,
    question:
        'You have hit a string of perfect 10s and feel a "rush" of excitement. How do you handle this sudden surge?',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(
          text: 'Acknowledge the success, exhale, and return to my technical process.',
          score: 4),
      AnswerOptionEntity(
          text: 'Enjoy the feeling but try to keep my physical movements steady.',
          score: 3),
      AnswerOptionEntity(
          text: 'Start thinking about the perfect score and feel my heart race.',
          score: 2),
      AnswerOptionEntity(
          text: 'Get overexcited and rush the next shot to keep the streak going.',
          score: 1),
    ],
  ),

  // ── DECISION STYLE (Q3, Q6, Q7, Q14, Q20) ────────────────────────────────

  BaselineQuestionEntity(
    id: 3,
    question:
        'The range officer calls "1 minute remaining" with two shots left. In this high-speed moment, what do you do?',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(
          text: 'Quickly stabilize my breath and trust my shot routine.',
          score: 4),
      AnswerOptionEntity(
          text: 'Speed up slightly while trying to maintain control.',
          score: 3),
      AnswerOptionEntity(
          text: 'Feel tense and shoot faster than normal.',
          score: 2),
      AnswerOptionEntity(
          text: 'Panic about the time and fire without a proper sight picture.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 4,
    question:
        'You feel a slight tremor in your physical hold during sighting. In this situation, what is your primary focus?',
    category: 'focus',
    options: [
      AnswerOptionEntity(
          text: 'Lower the weapon slightly and rebuild my hold calmly.',
          score: 4),
      AnswerOptionEntity(
          text: 'Wait for the tremor to settle before committing to the shot.',
          score: 3),
      AnswerOptionEntity(
          text: 'Try to "fight" the movement with extra muscle tension.',
          score: 2),
      AnswerOptionEntity(
          text: 'Feel discouraged and lose confidence in the shot.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 5,
    question:
        'You are performing exceptionally well and exceeding your PB. How do you keep your mind from drifting to the final score?',
    category: 'focus',
    options: [
      AnswerOptionEntity(
          text: 'Stay in the present and focus only on the next shot.',
          score: 4),
      AnswerOptionEntity(
          text: 'Tell myself not to think about the result.',
          score: 3),
      AnswerOptionEntity(
          text: 'Keep checking the scoreboard mentally.',
          score: 2),
      AnswerOptionEntity(
          text: 'Start imagining winning or breaking records.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 6,
    question:
        'You feel a coach\'s instruction may not be working for you today. Do you follow the advice or trust your gut?',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(
          text: 'Trial the instruction carefully while monitoring my rhythm.',
          score: 4),
      AnswerOptionEntity(
          text: 'Follow the coach while adjusting slightly to my comfort.',
          score: 3),
      AnswerOptionEntity(
          text: 'Reject the instruction and rely fully on instinct.',
          score: 2),
      AnswerOptionEntity(
          text: 'Get confused and lose clarity in execution.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 7,
    question:
        'You must choose between a "safe" shot or a risky, high-speed correction. What determines your decision?',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(
          text: 'Calculate the probability and trust my technical judgment.',
          score: 4),
      AnswerOptionEntity(
          text: 'Take the safer option under pressure.',
          score: 3),
      AnswerOptionEntity(
          text: 'Take the risk impulsively.',
          score: 2),
      AnswerOptionEntity(
          text: 'Hesitate for too long and lose timing.',
          score: 1),
    ],
  ),

  // ── MOTIVATION (Q8, Q10, Q12, Q25) ───────────────────────────────────────

  BaselineQuestionEntity(
    id: 8,
    question:
        'You are given technical feedback on your stance. What is your process for integrating this into muscle memory?',
    category: 'motivation',
    options: [
      AnswerOptionEntity(
          text: 'Use visualization and structured repetition in training.',
          score: 4),
      AnswerOptionEntity(
          text: 'Repeat the new stance consistently in practice.',
          score: 3),
      AnswerOptionEntity(
          text: 'Try the change inconsistently and forget details.',
          score: 2),
      AnswerOptionEntity(
          text: 'Feel frustrated and resist changing technique.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 9,
    question:
        'You face a highly skilled opponent in a head-to-head shoot-off. What is your primary goal during this confrontation?',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(
          text: 'Focus entirely on my own shot execution.',
          score: 4),
      AnswerOptionEntity(
          text: 'Remind myself to stay calm and competitive.',
          score: 3),
      AnswerOptionEntity(
          text: 'Keep glancing at the opponent\'s score.',
          score: 2),
      AnswerOptionEntity(
          text: 'Feel intimidated and pressured immediately.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 10,
    question:
        'You wake up feeling low energy on a match day. How do you "switch on" your performance mindset despite your mood?',
    category: 'motivation',
    options: [
      AnswerOptionEntity(
          text: 'Activate my competition routine and mental cues.',
          score: 4),
      AnswerOptionEntity(
          text: 'Push myself mentally to become match ready.',
          score: 3),
      AnswerOptionEntity(
          text: 'Feel uncertain whether performance will suffer.',
          score: 2),
      AnswerOptionEntity(
          text: 'Struggle to motivate myself for the match.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 11,
    question:
        'There is a sudden loud noise or electronic target malfunction nearby. How quickly do you return to your rhythm?',
    category: 'focus',
    options: [
      AnswerOptionEntity(
          text: 'Refocus almost immediately using my breathing routine.',
          score: 4),
      AnswerOptionEntity(
          text: 'Pause briefly and continue steadily.',
          score: 3),
      AnswerOptionEntity(
          text: 'Stay distracted for several shots.',
          score: 2),
      AnswerOptionEntity(
          text: 'Lose concentration completely.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 12,
    question:
        'You are doing repetitive dry-fire practice that feels boring. How do you maintain the quality of every trigger pull?',
    category: 'motivation',
    options: [
      AnswerOptionEntity(
          text: 'Treat every repetition like a competition shot.',
          score: 4),
      AnswerOptionEntity(
          text: 'Stay disciplined and complete the routine carefully.',
          score: 3),
      AnswerOptionEntity(
          text: 'Rush repetitions without full attention.',
          score: 2),
      AnswerOptionEntity(
          text: 'Mentally disengage from practice.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 13,
    question:
        'You notice your thoughts drifting to school or home during a series. What "anchor" do you use to bring focus back?',
    category: 'focus',
    options: [
      AnswerOptionEntity(
          text: 'Return attention to breathing and sight alignment.',
          score: 4),
      AnswerOptionEntity(
          text: 'Use a simple mental cue like "focus now."',
          score: 3),
      AnswerOptionEntity(
          text: 'Struggle to stop unrelated thoughts.',
          score: 2),
      AnswerOptionEntity(
          text: 'Become fully distracted from shooting.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 14,
    question:
        'The lighting or wind conditions at the range suddenly change. How do you adjust your focus to these variables?',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(
          text: 'Adapt calmly and adjust technique accordingly.',
          score: 4),
      AnswerOptionEntity(
          text: 'Make cautious corrections and continue.',
          score: 3),
      AnswerOptionEntity(
          text: 'Feel unsettled and lose rhythm temporarily.',
          score: 2),
      AnswerOptionEntity(
          text: 'Lose confidence in my ability to adapt.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 15,
    question:
        'You feel mentally tired halfway through a 60-shot match. What is your strategy to keep your concentration sharp?',
    category: 'focus',
    options: [
      AnswerOptionEntity(
          text: 'Mentally reset between shots and trust my routine.',
          score: 4),
      AnswerOptionEntity(
          text: 'Push through fatigue with discipline.',
          score: 3),
      AnswerOptionEntity(
          text: 'Notice increasing distractions and errors.',
          score: 2),
      AnswerOptionEntity(
          text: 'Mentally give up consistency.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 16,
    question:
        'You make a visible mistake (e.g., a 7 or 8) but must continue. In this moment, where does your internal dialogue go?',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(
          text: 'Toward calmly correcting the next shot.',
          score: 4),
      AnswerOptionEntity(
          text: 'Brief disappointment before refocusing.',
          score: 3),
      AnswerOptionEntity(
          text: 'Self-doubt about repeating mistakes.',
          score: 2),
      AnswerOptionEntity(
          text: 'Harsh negative self-criticism.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 17,
    question:
        'You experience multiple low-scoring shots in a row. What do you usually do to break this negative cycle?',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(
          text: 'Reset my breathing and return to fundamentals.',
          score: 4),
      AnswerOptionEntity(
          text: 'Slow down and carefully rebuild rhythm.',
          score: 3),
      AnswerOptionEntity(
          text: 'Feel anxious about continuing mistakes.',
          score: 2),
      AnswerOptionEntity(
          text: 'Panic and lose emotional control.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 18,
    question:
        'You return to the range after a long break. How do you handle the pressure of not being at your peak immediately?',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(
          text: 'Stay patient and trust gradual improvement.',
          score: 4),
      AnswerOptionEntity(
          text: 'Accept that rebuilding form takes time.',
          score: 3),
      AnswerOptionEntity(
          text: 'Feel frustrated with reduced performance.',
          score: 2),
      AnswerOptionEntity(
          text: 'Lose confidence quickly.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 19,
    question:
        'You fail to qualify for a final despite maximum effort. What is your immediate internal reaction to this failure?',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(
          text: 'Learn from the experience and prepare stronger.',
          score: 4),
      AnswerOptionEntity(
          text: 'Feel disappointed but motivated to improve.',
          score: 3),
      AnswerOptionEntity(
          text: 'Doubt my ability after the result.',
          score: 2),
      AnswerOptionEntity(
          text: 'Feel emotionally defeated.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 20,
    question:
        'You notice you are repeating the same technical mistake. In this situation, what is your process for self-correction?',
    category: 'decision_style',
    options: [
      AnswerOptionEntity(
          text: 'Analyze the mistake calmly and adjust deliberately.',
          score: 4),
      AnswerOptionEntity(
          text: 'Try gradual corrections during practice.',
          score: 3),
      AnswerOptionEntity(
          text: 'Become frustrated by repetition.',
          score: 2),
      AnswerOptionEntity(
          text: 'Feel helpless about improving it.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 21,
    question:
        'Your coach or a top competitor is standing directly behind you, watching. How does this change your performance?',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(
          text: 'Stay focused on my process and routine.',
          score: 4),
      AnswerOptionEntity(
          text: 'Feel pressure but remain composed.',
          score: 3),
      AnswerOptionEntity(
          text: 'Become self-conscious about performance.',
          score: 2),
      AnswerOptionEntity(
          text: 'Perform significantly worse under observation.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 22,
    question:
        'You receive direct, sharp criticism about your technique from a mentor. How do you process this feedback?',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(
          text: 'Use the criticism constructively to improve.',
          score: 4),
      AnswerOptionEntity(
          text: 'Feel uncomfortable but still listen carefully.',
          score: 3),
      AnswerOptionEntity(
          text: 'Take the criticism personally for some time.',
          score: 2),
      AnswerOptionEntity(
          text: 'Become emotionally upset and discouraged.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 23,
    question:
        'You are corrected or criticized in front of your teammates. How do you manage your emotional response?',
    category: 'emotional_stability',
    options: [
      AnswerOptionEntity(
          text: 'Stay professional and focus on learning.',
          score: 4),
      AnswerOptionEntity(
          text: 'Feel embarrassed but remain controlled.',
          score: 3),
      AnswerOptionEntity(
          text: 'Become defensive internally.',
          score: 2),
      AnswerOptionEntity(
          text: 'Feel humiliated and lose concentration.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 24,
    question:
        'An opponent is performing much better than you and receiving praise. How do you stay focused on your own target?',
    category: 'focus',
    options: [
      AnswerOptionEntity(
          text: 'Concentrate fully on my own process.',
          score: 4),
      AnswerOptionEntity(
          text: 'Acknowledge their performance but stay composed.',
          score: 3),
      AnswerOptionEntity(
          text: 'Compare myself negatively to them.',
          score: 2),
      AnswerOptionEntity(
          text: 'Feel discouraged and distracted.',
          score: 1),
    ],
  ),

  BaselineQuestionEntity(
    id: 25,
    question:
        'You succeed and receive high recognition. How do you ensure it does not lead to overconfidence?',
    category: 'motivation',
    options: [
      AnswerOptionEntity(
          text: 'Stay humble and continue disciplined training.',
          score: 4),
      AnswerOptionEntity(
          text: 'Enjoy success while remaining balanced.',
          score: 3),
      AnswerOptionEntity(
          text: 'Become overly focused on reputation.',
          score: 2),
      AnswerOptionEntity(
          text: 'Underestimate future challenges after success.',
          score: 1),
    ],
  ),
];
