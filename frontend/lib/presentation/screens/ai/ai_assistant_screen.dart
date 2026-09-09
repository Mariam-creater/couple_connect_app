import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _toneInputController = TextEditingController(
    text: "I was hoping we'd cook together tonight, but you seemed distant when you got home. Did I do something wrong, or are you just tired?",
  );

  final _romancePromptController = TextEditingController(
    text: "Expressing how grateful I am for her supporting me during the big project launch last week.",
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Relationship Assistant', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryRose,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Tone Scanner'),
            Tab(text: 'Romantic Writer'),
            Tab(text: 'Date Planner'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildToneScannerTab(appState),
          _buildRomanceWriterTab(appState),
          _buildDatePlannerTab(appState),
        ],
      ),
    );
  }

  // --- TAB 1: Tone Scanner ---
  Widget _buildToneScannerTab(AppState appState) {
    final analysis = appState.lastAiToneAnalysis;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Message Tone & Conflict Prevention Scanner',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          'Paste or type a draft message to analyze emotional temperature, respect score, and receive empathetic rephrasings.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),

        TextField(
          controller: _toneInputController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type your draft conversation here...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
        ),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          icon: const Icon(Icons.auto_awesome_rounded),
          label: appState.isAiLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Analyze Communication Tone'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRose,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: appState.isAiLoading
              ? null
              : () => appState.analyzeTone(_toneInputController.text.trim()),
        ),
        const SizedBox(height: 24),

        if (analysis != null) ...[
          Container(
            decoration: AppTheme.glassBox(context: context, borderColor: AppTheme.primaryRose.withOpacity(0.4)),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tone: ${analysis['tone'] ?? 'Warm'}', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Respect Score: ${analysis['respect_score'] ?? 88}%', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  analysis['summary_advice'] ?? 'A very constructive and caring message.',
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),

                const Text('Empathetic Suggestion:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (analysis['alternative_drafts'] as List?)?.first?.toString() ??
                        "Hey love, you looked exhausted after work today. Take all the time you need to unwind, and let me know if you'd like me to fix us dinner!",
                    style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- TAB 2: Romantic Writer ---
  Widget _buildRomanceWriterTab(AppState appState) {
    final generated = appState.lastAiGeneratedRomance;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Personalized Romantic Generator',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          'Craft emotionally deep love letters, sincere apologies, anniversary wishes, or poems.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),

        TextField(
          controller: _romancePromptController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Context & Key Emotion',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                onPressed: appState.isAiLoading
                    ? null
                    : () => appState.generateRomanticMessage(
                          type: 'love_letter',
                          keyMoments: _romancePromptController.text,
                        ),
                child: const Text('💌 Love Letter', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A273C)),
                onPressed: appState.isAiLoading
                    ? null
                    : () => appState.generateRomanticMessage(
                          type: 'apology',
                          keyMoments: _romancePromptController.text,
                        ),
                child: const Text('🕊️ Apology Note', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (generated != null) ...[
          Container(
            decoration: AppTheme.glassBox(context: context, borderColor: AppTheme.accentViolet.withOpacity(0.5)),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(generated['title'] ?? 'Our Heartfelt Bond', style: const TextStyle(color: AppTheme.accentGold, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  generated['generated_text'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                if (generated['delivery_tip'] != null)
                  Text(
                    '💡 Tip: ${generated['delivery_tip']}',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- TAB 3: Date Planner ---
  Widget _buildDatePlannerTab(AppState appState) {
    final plan = appState.lastAiDatePlan;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Tailored Couple Date & Trip Itinerary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          'Let AI plan an unforgettable evening or weekend trip matching your budget and romantic vibe.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),

        ElevatedButton.icon(
          icon: const Icon(Icons.explore_rounded),
          label: const Text('Generate Cozy Date Night Plan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRose,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => appState.planDate(vibe: 'Romantic, Candlelit & Cozy'),
        ),
        const SizedBox(height: 24),

        if (plan != null) ...[
          Container(
            decoration: AppTheme.glassBox(context: context, borderColor: AppTheme.accentGold.withOpacity(0.4)),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan['itinerary_title'] ?? 'Enchanted Evening', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(plan['highlight'] ?? '', style: TextStyle(color: AppTheme.accentGold, fontSize: 13)),
                const SizedBox(height: 16),

                if (plan['schedule'] is List) ...[
                  ...(plan['schedule'] as List).map((step) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.primaryRose.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text(step['time'] ?? '', style: const TextStyle(color: AppTheme.primaryRose, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(step['activity'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                if (step['note'] != null)
                                  Text(step['note']!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
