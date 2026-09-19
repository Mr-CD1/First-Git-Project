import 'dart:async';

import 'package:flutter/material.dart';

import '../data/asset_repository.dart';
import '../models/app_data.dart';
import '../models/app_theme_mode.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_top_bar.dart';
import 'account_form_screen.dart';
import 'home_screen.dart';
import 'monthly_savings_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.repository,
    this.onThemeModeChanged,
  });

  final AssetRepository repository;
  final ValueChanged<AppThemeMode>? onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    widget.onThemeModeChanged?.call(data.settings.themeMode);
  }

  Future<void> _persist(AppData data) async {
    await widget.repository.save(data);
    if (!mounted) {
      return;
    }
    setState(() => _appData = data);
    widget.onThemeModeChanged?.call(data.settings.themeMode);
  }

  void _handleThemeModeChange(AppThemeMode mode) {
    widget.onThemeModeChanged?.call(mode);
    if (_isLoading) {
      return;
    }

    final updated = _appData.updateSettings(
      _appData.settings.copyWith(themeMode: mode),
    );
    setState(() => _appData = updated);
    unawaited(widget.repository.save(updated));
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
      key: _scaffoldKey,
      appBar: _section == AppSection.home
          ? null
          : AppTopBar(title: _section.label),
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
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          onOpenMonthlyChart: () =>
              _onSectionSelected(AppSection.monthlySavings),
        );
      case AppSection.monthlySavings:
        return MonthlySavingsScreen(appData: _appData);
      case AppSection.settings:
        return SettingsScreen(
          appData: _appData,
          onSaved: _persist,
          onThemeModeChanged: _handleThemeModeChange,
        );
    }
  }
}
