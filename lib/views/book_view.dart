import 'dart:convert';
import 'package:flutter/material.dart';
import 'borrow_return.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BookView extends StatefulWidget {
  final Book book;
  final String userEmail;
  final String mostRecentReqStatus;

  BookView({
    required this.book,
    required this.userEmail,
    required this.mostRecentReqStatus,
  });

  @override
  _BookViewState createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  String? patronId;
  String? bookId;
  bool isBookRequested = false;
  List<dynamic> fetchedBookIds = [];
  String? latestReqStatus; // Add this line
  DateTime? selectedDate;
  bool hasSelectedDateTime = false;
  bool isRequestSent = false;
  bool showRequestSentModal = false;
  bool showConfirmationModal = false;
   bool isConfirmationPressed = false; 

  @override
  void initState() {
    super.initState();
    fetchPatronId();
    isBookRequested = fetchedBookIds.contains(widget.book.book_id);
    latestReqStatus = widget.mostRecentReqStatus; // Set the latest request status
  }

  void closeModal() {
    setState(() {
      showRequestSentModal = false;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime initialDate = selectedDate ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        hasSelectedDateTime = true; // Set the flag when a date and time are selected
        _showConfirmationModal();
      });
    }
  }

  Future<void> fetchPatronId() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/php-crud-api/get_pat_id.php?email=${widget.userEmail}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          patronId = data['patron_id'];
        });
      } else {
        // Handle error here
      }
    } catch (e) {
      // Handle exception here
    }
  }

  Future<void> borrowBook() async {
    if (patronId != null && selectedDate != null) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2/php-crud-api/book_req.php'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'pat_id': patronId,
            'book_id': widget.book.book_id,
            'date_req': '${DateFormat('yyyy-MM-dd').format(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day))}',
            'due_req': '${DateFormat('yyyy-MM-dd').format(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day).add(Duration(days: 6)))}'
          }),
        );

        if (response.statusCode == 200) {
          // Successfully borrowed the book
          await Future.delayed(Duration(milliseconds: 200));

          // Update the fetchedBookIds and isBookRequested after the borrow request
          setState(() {
            fetchedBookIds.add(int.parse(widget.book.book_id));
          });
        } else {
          // Handle error here
          print('Error: ${response.statusCode}');
        }

        // Check the request status after borrowing

      } catch (e) {
        // Handle exception here
        print('Exception: $e');
      }
    }
  }

  void _showRequestSentModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Request Sent"),
          content: Text("Your request has been sent."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                closeModal(); // Close the modal
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationModal() {
    String checkedOutDate = DateFormat('MMMM d, y').format(selectedDate!);
    String dueDate = DateFormat('MMMM d, y').format(selectedDate!.add(Duration(days: 6)));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to send the request?"),
              SizedBox(height: 16),
              Text("Borrow Date: $checkedOutDate"),
              Text("Return Date: $dueDate"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                closeModal();
                setState(() {
                  isConfirmationPressed = true; // Set the flag
                  _showRequestSentModal();
                  isRequestSent = true;
                  showRequestSentModal = true;
                  borrowBook();
                });
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Author: ${widget.book.author}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Category: ${widget.book.category}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Publication Date: ${widget.book.pub_date}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Content: ${widget.book.content}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: (latestReqStatus != 'Process' && !isBookRequested && !isConfirmationPressed)
              ? () async {
                  await _selectDateTime(context); // Show the date and time picker
                  if (showConfirmationModal != false) {
                    setState(() {
                      fetchedBookIds.add(widget.book.book_id);
                      isBookRequested = true;
                      isRequestSent = true;
                    });
                  }
                }
              : null,
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(Size(200, 60)),
          ),
          child: Text(
            latestReqStatus == "Process" || isRequestSent
                ? 'Waiting for Approval'
                : 'Request',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
