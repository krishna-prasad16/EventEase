import 'package:flutter/material.dart';
import 'package:admin/main.dart';

class ManageEvent extends StatefulWidget {
  const ManageEvent({super.key});

  @override
  State<ManageEvent> createState() => _ManageEventState();
}

class _ManageEventState extends State<ManageEvent>
    with SingleTickerProviderStateMixin {


  bool _isFormVisible = false; // To manage form visibility
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController eventController = TextEditingController();
 

  Future<void> eventSubmit() async {
    try {
      String eventtype = eventController.text;
      
      await supabase.from('tbl_eventtype').insert(
        {
          'eventtype_name' : eventtype,
          
        }
      );
      eventController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Inserted"), ));
    } catch (e) {
      print("ERROR ADDING EVENT: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 1000),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isFormVisible =
                          !_isFormVisible; // Toggle form visibility
                    });
                  },
                  label: Text(_isFormVisible ? "Cancel" : "Add EventType"),
                  icon: Icon(_isFormVisible ? Icons.cancel : Icons.add),
                ),
              )
            ],
          ),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? Form(
                    child: Column(
                    children: [
                      //F,orms
                      Form(
                          child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: eventController,
                                decoration: InputDecoration(
                              labelText: 'Event Type ',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero),
                            )),
                          ),
                          
                          ElevatedButton(
                              onPressed: () {
                                eventSubmit();
                              }, child: Text('Submit'))
                        ],
                      )),
                    ],
                  ))
                : Container(),
          ),
          Container(
            height: 500,
            child: Center(
              child: Text(
                "events",
                style: TextStyle(
                  fontSize: 20, // Adjust the size for emphasis
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}