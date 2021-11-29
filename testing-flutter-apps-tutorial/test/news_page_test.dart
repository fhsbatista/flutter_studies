import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;
  final articles = [
    Article(title: 'Test 1', content: 'Content 1'),
    Article(title: 'Test 2', content: 'Content 2'),
    Article(title: 'Test 3', content: 'Content 3'),
  ];

  setUp(() {
    mockNewsService = MockNewsService();
  });

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async => articles);
  }

  void arrangeNewsServiceReturns3ArticlesAfter2Seconds() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return articles;
    });
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: NewsPage(),
      ),
    );
  }

  testWidgets('title is displayed', (WidgetTester tester) async {
    arrangeNewsServiceReturns3Articles();
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('News'), findsOneWidget);
  });

  testWidgets(
    'loading indicator is displayed while waiting for articles',
    (tester) async {
      arrangeNewsServiceReturns3ArticlesAfter2Seconds();
      await tester.pumpWidget(createWidgetUnderTest());

      ///To make sure the NewsPage will have time to
      ///perform the all needed work that makes de indicator appears.
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'articles are displayed',
    (tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      for (final article in articles) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
