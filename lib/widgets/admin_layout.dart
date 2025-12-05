import 'package:flutter/material.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_users_screen.dart';
import '../screens/admin_berita_screen.dart';
import '../screens/admin_kategori_screen.dart';
import '../services/auth_service.dart';

class AdminLayout extends StatefulWidget {
  final Widget? initialScreen;
  const AdminLayout({super.key, this.initialScreen});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  final AuthService _authService = AuthService();

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      icon: Icons.dashboard,
      title: 'Dashboard',
      screen: const AdminDashboardScreen(),
    ),
    AdminMenuItem(
      icon: Icons.people,
      title: 'Manajemen Users',
      screen: const AdminUsersScreen(),
    ),
    AdminMenuItem(
      icon: Icons.article,
      title: 'Manajemen Berita',
      screen: const AdminBeritaScreen(),
    ),
    AdminMenuItem(
      icon: Icons.category,
      title: 'Kategori Berita',
      screen: const AdminKategoriScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar - Collapsible
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarExpanded ? 250 : 70,
            color: Colors.grey[900],
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(_isSidebarExpanded ? 20 : 16),
                  decoration: BoxDecoration(color: Colors.purple[900]),
                  child: Row(
                    mainAxisAlignment: _isSidebarExpanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                      if (_isSidebarExpanded) ...[
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Admin Panel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // User Info
                Container(
                  padding: EdgeInsets.all(_isSidebarExpanded ? 16 : 12),
                  color: Colors.grey[800],
                  child: _isSidebarExpanded
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.purple,
                              child: Text(
                                _authService.currentUser?.displayName?[0]
                                        .toUpperCase() ??
                                    _authService.currentUser?.email?[0]
                                        .toUpperCase() ??
                                    'A',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _authService.currentUser?.displayName ??
                                          'Admin',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Flexible(
                                    child: Text(
                                      _authService.currentUser?.email ?? '',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.purple,
                          child: Text(
                            _authService.currentUser?.displayName?[0]
                                    .toUpperCase() ??
                                _authService.currentUser?.email?[0]
                                    .toUpperCase() ??
                                'A',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                ),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == index;

                      return Tooltip(
                        message: _isSidebarExpanded ? '' : item.title,
                        child: ListTile(
                          selected: isSelected,
                          // ignore: deprecated_member_use
                          selectedTileColor: Colors.purple.withOpacity(0.2),
                          leading: Icon(
                            item.icon,
                            color: isSelected
                                ? Colors.purple[300]
                                : Colors.grey[400],
                          ),
                          title: _isSidebarExpanded
                              ? Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                )
                              : null,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: _isSidebarExpanded ? 16 : 20,
                            vertical: 8,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Logout Button
                Container(
                  padding: EdgeInsets.all(_isSidebarExpanded ? 16 : 12),
                  child: _isSidebarExpanded
                      ? ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi Logout'),
                                content: const Text(
                                  'Apakah Anda yakin ingin keluar?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && mounted) {
                              await _authService.logout();
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                  (route) => false,
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        )
                      : Tooltip(
                          message: 'Logout',
                          child: IconButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi Logout'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin keluar?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && mounted) {
                                await _authService.logout();
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.logout),
                            color: Colors.red,
                            style: IconButton.styleFrom(
                              // ignore: deprecated_member_use
                              backgroundColor: Colors.red.withOpacity(0.1),
                              minimumSize: const Size(48, 48),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Divider
          GestureDetector(
            onTap: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
            child: Container(
              width: 4,
              color: Colors.grey[300],
              child: Center(
                child: Container(
                  width: 2,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: Column(
              children: [
                // AppBar dengan toggle button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSidebarExpanded ? Icons.menu_open : Icons.menu,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSidebarExpanded = !_isSidebarExpanded;
                          });
                        },
                        tooltip: _isSidebarExpanded
                            ? 'Collapse Sidebar'
                            : 'Expand Sidebar',
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _menuItems[_selectedIndex].title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Screen Content
                Expanded(child: _menuItems[_selectedIndex].screen),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminMenuItem {
  final IconData icon;
  final String title;
  final Widget screen;

  AdminMenuItem({
    required this.icon,
    required this.title,
    required this.screen,
  });
}
