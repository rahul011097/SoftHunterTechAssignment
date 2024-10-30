import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:skyline_project/scheme_data.dart';
import "commonTextWidget.dart";
import 'package:http/http.dart' as http;

class ContentWidget extends StatefulWidget {
  final String? token;
  const ContentWidget({Key? key, this.token}) : super(key: key);

  @override
  State<ContentWidget> createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  final Set<int> expandedIndices = {0, 1};
  //final TextEditingController searchController = TextEditingController();
  //List<Map<String, String>> filteredSchemes = [];
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  List<Data> schemes = [];
  bool isLoading = false;
  bool hasMore = true;
  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        "https://test.bookinggksm.com/api/scheme/view-scheme/55?page=$currentPage");
    final response = await http
        .get(url, headers: {'Authorization': 'Bearer ${widget.token}'});
    print("hiiii ${widget.token ?? ""}");

    if (response.statusCode == 200) {
      final data = SchemesDataResponse.fromJson(jsonDecode(response.body));
      print('Response body: ${response.body}');

      // Corrected the condition to check for null
      if (data.result != null && data.result?.properties != null) {
        List<Data> newProperties =
            data.result?.properties?.data ?? []; // Use '!' to assert non-null

        setState(() {
          // Add properties to the schemes list
          schemes.addAll(newProperties.map((scheme) => Data(
                schemeName: scheme.schemeName,
                plotName: scheme.plotName,
                plotNo: scheme.plotNo,
                plotType: scheme.plotType,
                propertyStatus: scheme.propertyStatus,
                attributesData: scheme.attributesData,
              )));
          currentPage++;
          isLoading = false;
          if (newProperties.isEmpty) {
            hasMore = false;
          }
        });
      } else {
        // Handle unexpected data format
        setState(() {
          isLoading = false;
          hasMore = false;
        });
        print('Unexpected data format: ${data.toString()}');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load schemes. Status code: ${response.statusCode}');
      throw Exception('Failed to load schemes');
    }
  }

  String formatAttributes(Data scheme) {
    final Map<String, dynamic> attributes =
        jsonDecode(scheme.attributesData ?? "");
    List<String> formattedAttributes = [];

    // Add PlotType field at the start
    formattedAttributes.add("${scheme.plotType}-");

    // Add other attributes
    attributes.forEach((key, value) {
      formattedAttributes.add("$key:$value");
    });

    return formattedAttributes.join(',');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   filteredSchemes = schemes; // Initially show all schemes
  //   searchController.addListener(_filterSchemes); // Add listener for search
  // }

  // @override
  // void dispose() {
  //   searchController.dispose();
  //   super.dispose();
  // }

  // void _filterSchemes() {
  //   final query = searchController.text.toLowerCase();
  //   setState(() {
  //     filteredSchemes = schemes.where((scheme) {
  //       final title = scheme['title']?.toLowerCase() ?? '';
  //       final status = scheme['status']?.toLowerCase() ?? '';
  //       return title.contains(query) || status.contains(query);
  //     }).toList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Color(0xFF03467D),
        title: Column(
          children: [
            const Text(
              "View Schemes",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              // controller: searchController,
              decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'enter... unit no, type, status',
                  contentPadding: EdgeInsets.all(0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.white))),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: schemes.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == schemes.length) {
              return isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox.shrink();
            }
            final scheme = schemes[index];
            print("hiuiii ${scheme.attributesData}");
            final isExpanded = expandedIndices.contains(index);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    expandedIndices.remove(index); // Collapse item
                  } else {
                    expandedIndices.add(index); // Expand item
                  }
                });
              },
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ("${scheme.plotType ?? ""}-${scheme.plotName ?? ""}"),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF43366E)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                scheme.schemeName ?? "",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Text(
                          //   scheme.propertyStatus ?? "",
                          //   style: TextStyle(
                          //       fontSize: 16,
                          //       color: Colors.grey[600],
                          //       fontWeight: FontWeight.bold),
                          // ),
                          Text(
                            (scheme.propertyStatus ==
                                    "1") // Directly compare with integers
                                ? "Available"
                                : (scheme.propertyStatus == "2")
                                    ? "Booked"
                                    : (scheme.propertyStatus == "3")
                                        ? "Hold"
                                        : (scheme.propertyStatus == "4")
                                            ? "Cancel"
                                            : (scheme.propertyStatus == "5")
                                                ? "Complete"
                                                : "Unknown", // Default case
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (isExpanded) ...[
                        Divider(),
                        SizedBox(height: 8),
                        if ((scheme.attributesData ?? '').isNotEmpty)
                          Text(
                            formatAttributes(scheme),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Thank you for booking this."),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(
                                  0xFF03467D), // Customize button color here
                            ),
                            child: Text(
                              'Book/Hold',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getPropertyStatusText(int? status) {
    switch (status) {
      case 1:
        return "Available";
      case 2:
        return "Booked";
      case 3:
        return "Hold";
      case 4:
        return "Cancel";
      case 5:
        return "Complete";
      default:
        return "Unknown"; // Default case if status is null or not matched
    }
  }
}
