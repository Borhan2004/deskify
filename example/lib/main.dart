import 'package:flutter/material.dart';
import 'package:deskify/deskify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DeskifyExampleApp());
}

class DeskifyExampleApp extends StatelessWidget {
  const DeskifyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deskify Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern Indigo
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF818CF8),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: .05)),
          ),
          color: const Color(0xFF1E293B),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DeskAccelerator(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): () {
          _showAddTaskDialog(context);
        },
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): () {
          _showAddTaskDialog(context);
        },
      },
      child: DeskShell(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Deskify',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Master Suite',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: .7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          DeskDestination(
            icon: Icons.grid_view_rounded,
            selectedIcon: Icons.grid_view_rounded,
            label: 'Dashboard',
          ),
          DeskDestination(
            icon: Icons.task_alt_rounded,
            selectedIcon: Icons.task_alt_rounded,
            label: 'Tasks',
          ),
          DeskDestination(
            icon: Icons.calendar_month_rounded,
            selectedIcon: Icons.calendar_month_rounded,
            label: 'Schedule',
          ),
          DeskDestination(
            icon: Icons.settings_rounded,
            selectedIcon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSidebarStat('74%', 'Productivity'),
            const SizedBox(height: 24),
            HoverDecorator(
              onHoverScale: 1.05,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: .3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF6366F1),
                      child: Text(
                        'JD',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('John Doe', style: theme.textTheme.labelLarge),
                          Text('Pro Plan', style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                    Icon(Icons.more_vert, size: 18, color: theme.hintColor),
                  ],
                ),
              ),
            ),
          ],
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildSidebarStat(String val, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: .1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.74,
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
      case 1:
        return const TodoListPage();
      default:
        return Center(
          child: Text(
            'Coming Soon',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Task'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Due date',
                      prefixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Chip(label: Text('Priority')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Create Task'),
          ),
        ],
      ),
    );
  }
}

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DeskConstraintBox(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning, John!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You have 12 tasks to complete today.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildActionButton(context),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: .2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tasks, projects, or notes...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTaskCard(context, index),
                  childCount: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return HoverDecorator(
      onHoverScale: 1.05,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              const Color(0xFF818CF8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(14),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'New Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isCompleted = index % 3 == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DeskRightClickMenu(
        items: [
          DeskContextMenuItem(
            label: 'Quick Edit',
            icon: Icons.bolt,
            onTap: () {},
          ),
          DeskContextMenuItem(
            label: 'Duplicate',
            icon: Icons.copy,
            onTap: () {},
          ),
          DeskContextMenuItem(
            label: 'Delete',
            icon: Icons.delete_outline,
            onTap: () {},
          ),
        ],
        child: HoverDecorator(
          onHoverScale: 1.01,
          onHoverColor: theme.colorScheme.primary.withValues(alpha: .02),
          child: Card(
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildAnimatedCheckbox(context, isCompleted),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index == 0
                                ? 'Implement Deskify Premium Shell'
                                : 'Weekly sync with design team',
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? theme.hintColor : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: theme.hintColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Mar 12, 2024',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  index % 2 == 0 ? 'Work' : 'Personal',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_horiz, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCheckbox(BuildContext context, bool checked) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: checked
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: checked
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : null,
    );
  }
}
