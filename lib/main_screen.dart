import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0=main,1=profile,2.. others

  @override
  void initState() {
    super.initState();
    // Sidebar stays visible at all times; nothing to initialize here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top thin translucent banner with stylized app name and logout
          Container(
            width: double.infinity,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Color.fromRGBO(165, 42, 42, 0.08)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    'Ichamba',
                    style: TextStyle(
                      color: Colors.brown[700],
                      fontStyle: FontStyle.italic,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(blurRadius: 2, color: Colors.brown.shade200),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    tooltip: 'Salir',
                    onPressed: () async {
                      await SupabaseService.signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (r) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ),
              ],
            ),
          ),

          // Main content: sidebar + content area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sidebarWidth = constraints.maxWidth * 0.22;

                return Row(
                  children: [
                    Container(
                      width: sidebarWidth,
                      color: const Color(0xFFEFF2F5),
                      child: SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _buildSidebarButtons(context),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: _buildContentForIndex(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconGrid() {
    final items = List.generate(24, (index) => 'Opción ${index + 1}');

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // aim ~200-240px per item; compute columns accordingly
        int crossAxisCount = (width / 220).floor();
        if (crossAxisCount < 1) crossAxisCount = 1;
        if (crossAxisCount > 6) crossAxisCount = 6;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final label = items[index];
            return Card(
              elevation: 1,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apps, size: 36, color: Colors.blueGrey[700]),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContentForIndex() {
    switch (_selectedIndex) {
      case 1:
        return const ProfilePage();
      case 0:
      default:
        return _buildIconGrid();
    }
  }

  List<Widget> _buildSidebarButtons(BuildContext context) {
    // Left menu: 6 icons. 1=Main menu, 2=Profile (edit user data), then others.
    final items = [
      {
        'icon': Icons.menu,
        'tooltip': 'Menú principal',
        'action': () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      },
      {
        'icon': Icons.person,
        'tooltip': 'Perfil',
        'action': () {
          setState(() {
            _selectedIndex = 1;
          });
        },
      },
      {
        'icon': Icons.notifications,
        'tooltip': 'Notificaciones',
        'action': () {},
      },
      {'icon': Icons.calendar_month, 'tooltip': 'Calendario', 'action': () {}},
      {
        'icon': Icons.chat_bubble_outline,
        'tooltip': 'Mensajes',
        'action': () {},
      },
      {'icon': Icons.settings, 'tooltip': 'Ajustes', 'action': () {}},
    ];

    // Render icon with label beneath and active highlight
    return items.asMap().entries.map((entry) {
      final idx = entry.key;
      final it = entry.value;
      final active = _selectedIndex == idx;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: GestureDetector(
          onTap: it['action'] as void Function()?,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: active ? Colors.blue.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  it['icon'] as IconData,
                  size: 28,
                  color: active ? Colors.blue : Colors.black87,
                ),
                const SizedBox(height: 6),
                Text(
                  it['tooltip'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: active ? Colors.blue : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
