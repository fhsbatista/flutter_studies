import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/article_page.dart';
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

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: NewsPage(),
      ),
    );
  }

  testWidgets("""tapping on the first article opens the article page
    where the full article content is displayed""", (tester) async {
    arrangeNewsServiceReturns3Articles();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.tap(find.text(articles.first.content));
    await tester.pumpAndSettle();
    expect(find.byType(NewsPage), findsNothing);
    expect(find.byType(ArticlePage), findsOneWidget);
    expect(find.text(articles.first.title), findsOneWidget);
    expect(find.text(articles.first.content), findsOneWidget);
  });
}
