import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Map<String, dynamic> assignedToUser = {};
bool isPermanent = false;

void updateTask(String name, String description, int reward, int routineId,
    Map<String, dynamic> userData, Map<String, dynamic> task) async {
  // Update task
  final Map<String, dynamic> variables = {
    'id': task['id'],
    'householdId': userData['householdId'],
    'routineId': routineId,
    'name': name,
    'deadline': DateTime.now().toIso8601String().split('.')[0] + 'Z',
    'description': description,
    'reward': reward,
    'status': 0
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
document: gql(
  r'''mutation UpdateTask($id: Int!, $userId: Int, $householdId: Int, $routineId: Int, $name: String, $deadline: String, $description: String, $reward: Int, $completed: Boolean) {
    updateTask(id: $id, userId: $userId, householdId: $householdId, routineId: $routineId, name: $name, deadline: $deadline, description: $description, reward: $reward, completed: $completed) {
      id
      householdId
      routineId
      name
      deadline
      description
      reward
      completed
    }
  }
  '''
),
    variables: variables,
  );
    try {
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      // Handle the result
      print(result.data);
      print("pushed the new item to the db: $variables");
    }
  } catch (e) {
    print(e);
  }
}

class DetailedTaskView extends StatefulWidget {
  const DetailedTaskView(
      {super.key, required this.task, required this.userData});

  final Map<String, dynamic> task;
  final Map<String, dynamic> userData;

  @override
  State<DetailedTaskView> createState() => _DetailedTaskViewState(task: task);
}

class _DetailedTaskViewState extends State<DetailedTaskView> {
  _DetailedTaskViewState({required this.task});

  bool required = false;
  final Map<String, dynamic> task;

  late TextEditingController taskName = TextEditingController();
  late TextEditingController taskPrice = TextEditingController();
  late TextEditingController description = TextEditingController();

  void _updateRequired() {
    setState(() {
      required = _checkInputs(); // Update required based on inputs
    });
  }

  bool _checkInputs() {
    return taskName.text.isNotEmpty &&
        taskPrice.text.isNotEmpty &&
        assignedToUser.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    taskName.addListener(_updateRequired);
    taskPrice.addListener(_updateRequired);
    description.addListener(_updateRequired);
  }

  void changePermanent() {
    setState(() {});
    isPermanent = !isPermanent;
  }

  @override
  Widget build(BuildContext context) {
    print(task);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const BackIconRow(),
              Align(
                alignment: Alignment.topLeft,
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: taskName,
                        decoration: InputDecoration.collapsed(
                          hintText: task['name'],
                          hintStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    changePermanent();
                  });
                },
                child: Padding(
                  // Hinzufügen von Padding um den Container
                  padding: const EdgeInsets.only(
                      top: 40), // Verschieben Sie den Slider nach unten
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x7FD9D9D9),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedAlign(
                          alignment: isPermanent
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  'repeat_txt'.tr,
                                  style: TextStyle(
                                    color: isPermanent
                                        ? Colors.black
                                        : const Color(0xFF4A4646),
                                    fontSize: 20,
                                    fontFamily: 'Karla',
                                    fontWeight: isPermanent
                                        ? FontWeight.w700
                                        : FontWeight.w300,
                                    height: 0,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'only_once_txt'.tr,
                                  style: TextStyle(
                                    color: !isPermanent
                                        ? Colors.black
                                        : const Color(0xFF4A4646),
                                    fontSize: 20,
                                    fontFamily: 'Karla',
                                    fontWeight: !isPermanent
                                        ? FontWeight.w700
                                        : FontWeight.w300,
                                    height: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              //Assign to...
              isPermanent
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 10, right: 20, bottom: 10),
                          child: Icon(
                            CupertinoIcons.clock_fill,
                            size: 40,
                            color: Color.fromARGB(255, 204, 198, 196),
                          ),
                        ),
                        Text(
                          ('repeats_txt'.tr),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )
                  : Container(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10, right: 20),
                    child: Icon(
                      CupertinoIcons.add_circled,
                      size: 40,
                      color: Color.fromARGB(255, 204, 198, 196),
                    ),
                  ),
                  Text(
                    'price:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Expanded(
                    child: TextField(
                      cursorColor: Theme.of(context).colorScheme.onSecondary,
                        textAlign: TextAlign.end,
                        controller: taskPrice,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            hintText: task['reward'].toString(),
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            border: InputBorder.none),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10, bottom: 10, right: 20),
                        child: Icon(
                          CupertinoIcons.text_aligncenter,
                          size: 40,
                          color: Color.fromARGB(255, 204, 198, 196),
                        ),
                      ),
                      Expanded(
                          child: Text(
                        'description',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodySmall,
                      )),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextField(
                        textInputAction: TextInputAction.done, // Add this line
                          onEditingComplete: () => FocusScope.of(context).unfocus(), // Add this line
                        cursorColor: Theme.of(context).colorScheme.onSecondary,
                          maxLines: 3,
                          controller: description,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: task['description'].isEmpty
                                  ? 'No description'
                                  : task['description'],
                              hintStyle: TextStyle(
                                  color: task['description'].isEmpty
                                      ? const Color.fromARGB(255, 204, 198, 196)
                                      : const Color.fromARGB(255, 74, 70, 70),
                                  fontSize: 20),
                              border: InputBorder.none),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      const Color.fromARGB(255, 74, 70, 70))))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 74, 70, 70),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                strokeAlign: BorderSide.strokeAlignOutside,
                                width: 5,
                                color: const Color.fromARGB(255, 74, 70, 70)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(61, 109, 103, 103),
                                offset: Offset(5.0, 5.0),
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              )
                            ]),
                        child: TextButton(
                          onPressed: () {
                            print(taskName.text);
                            print(taskPrice.text);
                            print(assignedToUser);
                            print(description.text);
                            if (taskName.text.isEmpty) {
                              taskName.text = task['name'];
                            }
                            if(taskPrice.text.isEmpty) {
                              taskPrice.text = task['reward'].toString();
                            }
                            if(description.text.isEmpty) {
                              description.text = task['description'];
                            }
                            updateTask(
                                taskName.text,
                                description.text,
                                int.parse(taskPrice.text),
                                task['routineId'],
                                widget.userData, task);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainWidget(userId: widget.userData['id'])),
                              (route) => false,
                            ).then((value) {
                              Get.forceAppUpdate();
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(
                                top: 10, bottom: 10, left: 15, right: 15),
                            child: Text("Save",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 243, 243, 243),
                                  fontFamily: "Karla",
                                  fontSize: 30,
                                )),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                              strokeAlign: BorderSide.strokeAlignOutside,
                              width: 5,
                              color: const Color.fromARGB(255, 204, 198, 196)),
                          color: const Color.fromARGB(255, 243, 243, 243),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(
                                top: 10, bottom: 10, left: 15, right: 15),
                            child: Text(
                              "Back",
                              style: TextStyle(
                                color: Color.fromARGB(255, 204, 198, 196),
                                fontFamily: "Karla",
                                fontSize: 30,
                              ),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
