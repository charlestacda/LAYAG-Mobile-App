import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lpu_app/views/book_view.dart';

class BookRequest {
  final String bookId;
  final String mostRecentReqStatus;

  BookRequest({
    required this.bookId,
    required this.mostRecentReqStatus,
  });
}

class Book {
  final String book_id;
  final String title;
  final String category;
  final String author;
  final String pub_date;
  final String content;
  final String book_status;
  List<BookRequest> requestList;

  Book({
    required this.book_id,
    required this.title,
    required this.category,
    required this.author,
    required this.pub_date,
    required this.content,
    required this.book_status,
    required this.requestList,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      book_id: json['book_id'],
      title: json['title'],
      author: json['author'],
      category: json['category'],
      pub_date: json['pub_date'],
      content: json['content'],
      book_status: json['book_status'],
      requestList: [], // Initialize an empty list of requests
    );
  }
}

class BookCard extends StatelessWidget {
  final String book_id;
  final String title;
  final String author;
  final String category;
  final String pub_date;
  final List<BookRequest> requestList;

  BookCard({
    required this.book_id,
    required this.title,
    required this.author,
    required this.category,
    required this.pub_date,
    required this.requestList,
  });

  @override
  Widget build(BuildContext context) {
    String mostRecentReqStatus = '';
    if (requestList.isNotEmpty) {
      mostRecentReqStatus = requestList.last.mostRecentReqStatus;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              author,
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              category,
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              pub_date,
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class BorrowReturn extends StatefulWidget {
  final String userEmail;
  const BorrowReturn({Key? key, required this.userEmail}) : super(key: key);

  @override
  BorrowReturnState createState() => BorrowReturnState();
}

class BorrowReturnState extends State<BorrowReturn> {
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/php-crud-api/get.php'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('posts')) {
          List<dynamic> bookList = jsonData['posts'];

          List<Book> fetchedBooks = bookList.map((json) => Book.fromJson(json)).toList();

          setState(() {
            books = fetchedBooks;
          });

          // Fetch most_recent_req_status for each book
          await fetchMostRecentReqStatusForBooks();
        } else {
          print('Error: The API response does not contain a "books" key.');
        }
      } else {
        print('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  Future<void> fetchMostRecentReqStatusForBooks() async {
    for (var book in books) {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2/php-crud-api/dis_req.php?book_id=${book.book_id}'),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final mostRecentReqStatus = responseData['most_recent_req_status'];

          setState(() {
            book.requestList.add(BookRequest(
              bookId: book.book_id,
              mostRecentReqStatus: mostRecentReqStatus,
            ));
          });
        } else {
          print('Failed to load request status for book_id ${book.book_id}: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching request statuses: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 168, 44, 60),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
          ),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          if (index < books.length) {
            var book = books[index];
            return GestureDetector(
              onTap: () async {
                await fetchMostRecentReqStatusForBooks();
                String mostRecentReqStatus = '';
                if (book.requestList.isNotEmpty) {
                  mostRecentReqStatus = book.requestList.last.mostRecentReqStatus;
                }
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookView(
                    book: books[index],
                    userEmail: widget.userEmail,
                    mostRecentReqStatus: mostRecentReqStatus,
                  ),
                ),
              ).then((value) {
                // This callback will be executed when the BookView is popped
                fetchBooks(); // Refresh the page to immediately reflect the updated status
              });
              },
              child: BookCard(
                book_id: book.book_id,
                title: book.title,
                author: book.author,
                category: book.category,
                pub_date: book.pub_date,
                requestList: book.requestList,
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
