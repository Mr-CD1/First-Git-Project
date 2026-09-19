import 'package:flutter/material.dart';

import '../data/asset_repository.dart';
import '../models/app_data.dart';
import '../widgets/app_drawer.dart';
import 'account_form_screen.dart';
import 'home_screen.dart';
import 'monthly_savings_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.repository,
  });

  final AssetRepository repository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppData _appData;
  bool _isLoading = true;
  AppSection _section = AppSection.home;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await widget.repository.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _appData = data;
      _isLoading = false;
    });
  }

  Future<void> _persist(AppData data) async {
    await widget.repository.save(data);
    if (!mounted) {
      return;
    }
    setState(() => _appData = data);
  }

  void _onSectionSelected(AppSection section) {
    setState(() => _section = section);
  }

  Future<void> _openAccountForm() async {
    final result = await Navigator.of(context).push<AppData>(
      MaterialPageRoute(
        builder: (context) => AccountFormScreen(appData: _appData),
      ),
    );
    if (result != null) {
      await _persist(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_section.label),
        centerTitle: false,
      ),
      drawer: AppDrawer(
        selectedSection: _section,
        onSectionSelected: _onSectionSelected,
      ),
      body: _buildBody(),
      floatingActionButton: _section == AppSection.home
          ? HomeFab(onPressed: _openAccountForm)
          : null,
    );
  }

  Widget _buildBody() {
    switch (_section) {
      case AppSection.home:
        return HomeScreen(
          appData: _appData,
          onAppDataChanged: _persist,
          onOpenMonthlyChart: () =>
              _onSectionSelected(AppSection.monthlySavings),
        );
      case AppSection.monthlySavings:
        return MonthlySavingsScreen(appData: _appData);
      case AppSection.settings:
        return SettingsScreen(
          appData: _appData,
          onSaved: _persist,
        );
    }
  }
}
