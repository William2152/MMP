import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool pushNotifications = false;
  bool promoNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pushNotifications = prefs.getBool('pushNotifications') ?? false;
      promoNotifications = prefs.getBool('promoNotifications') ?? false;
    });
  }

  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = BlocProvider.of<AuthBloc>(context);
      authBloc.add(CheckUserData());
    });
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        } else if (state is UserDataIncomplete) {
          Navigator.pushReplacementNamed(context, '/weight');
        }
      },
      builder: (context, state) {
        if (state is AuthSuccess) {
          return _buildAuthenticatedUI(context, state.user);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAuthenticatedUI(BuildContext context, UserModel user) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileSection(user),
            const SizedBox(height: 32),
            _buildAccountSection(),
            _buildNotificationSection(),
            _buildMoreSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(UserModel user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user.email,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      'My Account',
      [
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Personal Information',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.language,
          title: 'Language',
          trailing: 'English (US)',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.settings_outlined,
          title: 'Setting',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      'Notifications',
      [
        _buildSwitchMenuItem(
          icon: Icons.notifications_none,
          title: 'Push Notifications',
          value: pushNotifications,
          onChanged: (value) {
            setState(() {
              pushNotifications = value;
            });
            _saveNotificationSetting('pushNotifications', value);
          },
        ),
        _buildSwitchMenuItem(
          icon: Icons.campaign_outlined,
          title: 'Promotional Notifications',
          value: promoNotifications,
          onChanged: (value) {
            setState(() {
              promoNotifications = value;
            });
            _saveNotificationSetting('promoNotifications', value);
          },
        ),
      ],
    );
  }

  Widget _buildMoreSection(BuildContext context) {
    return _buildSection(
      'More',
      [
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help Center',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Log Out',
          titleColor: Colors.red,
          onTap: () {
            context.read<AuthBloc>().add(SignOut());
          },
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...items,
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailing,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: titleColor ?? Colors.black87,
        ),
      ),
      trailing: trailing != null
          ? Text(
              trailing,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            )
          : Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }
}
