import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import 'review_screen.dart';
import 'login_screen.dart'; // import login screen
import 'history_screen.dart'; // import session history screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _topicController = TextEditingController();
  int _questionCount = 5;
  String _difficulty = 'easy';
  bool _loading = false;
  User? _user; // Store the current user

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  Future<void> _startReview() async {
    if (_topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic to continue')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final questions = await AIService.generateQuestions(
        _topicController.text,
        _questionCount,
        _difficulty,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(questions: questions),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load questions: $e'),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Flashcards'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  'AI Flashcards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  ListTile(
                    leading: Icon(_user == null ? Icons.login : Icons.logout),
                    title: Text(_user == null ? 'Login / Register' : 'Logout'),
                    onTap: () {
                      Navigator.pop(context); // close drawer
                      if (_user == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      } else {
                        FirebaseAuth.instance.signOut();
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Session History'),
                    onTap: () {
                      Navigator.pop(context); // close drawer
                      if (_user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in first')),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SessionHistoryScreen(userId: _user!.uid)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6T8gslBzcjQ4TkiY22z1Eox1F1V0gLymTsQ&usqp=CAU',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: kToolbarHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 32),
                _buildInputSection(),
                const SizedBox(height: 40),
                _buildStartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to AI Flashcards!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter a topic, choose your settings, and start learning with AI-generated flashcards.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
        )
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        TextField(
          controller: _topicController,
          decoration: InputDecoration(
            labelText: 'Study Topic',
            hintText: 'e.g., Machine Learning, World History',
            prefixIcon: const Icon(Icons.book_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildDropdownCard(
                icon: Icons.format_list_numbered_rounded,
                title: 'Questions',
                child: DropdownButton<int>(
                  value: _questionCount,
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: _loading
                      ? null
                      : (val) => setState(() => _questionCount = val!),
                  items: [5, 10, 15]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text('$e questions'),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownCard(
                icon: Icons.speed_rounded,
                title: 'Difficulty',
                child: DropdownButton<String>(
                  value: _difficulty,
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: _loading
                      ? null
                      : (val) => setState(() => _difficulty = val!),
                  items: ['easy', 'medium', 'hard']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e[0].toUpperCase() + e.substring(1)),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: _loading ? null : _startReview,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded),
                SizedBox(width: 8),
                Text(
                  'Start Review Session',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }
}
