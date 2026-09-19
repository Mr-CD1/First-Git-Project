import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_2/data/asset_repository.dart';
import 'package:flutter_application_2/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home screen shows empty state initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(repository: AssetRepository()));
    await tester.pumpAndSettle();

    expect(find.text('资产总览'), findsOneWidget);
    expect(find.text('还没有记录任何资产'), findsOneWidget);
    expect(find.text('每月记账'), findsOneWidget);
    expect(find.text('添加账户'), findsWidgets);
  });

  testWidgets('Drawer navigates to monthly savings chart',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(repository: AssetRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('打开导航菜单'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('月度留存'));
    await tester.pumpAndSettle();

    expect(find.text('暂无留存数据'), findsOneWidget);
  });
}
