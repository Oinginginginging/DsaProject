import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prototype/getX/data_controller.dart';

class CalendarDay extends StatefulWidget {
  final DataController dataController;
  const CalendarDay(this.dataController, {Key? key}) : super(key: key);

  @override
  State<CalendarDay> createState() => _CalendarDayState();
}

class _CalendarDayState extends State<CalendarDay> {
  DateTime currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late Map<DateTime, List<TodoItem>> todoLists;
  late Map<DateTime, String> memos;
  late DataController dataController;

  TextEditingController todoController = TextEditingController();
  TextEditingController memoController = TextEditingController();

  @override
  void dispose() {
    todoController.dispose();
    memoController.dispose();
    super.dispose();
  }

  void _yesterday() {
    _updateDate(currentDate.subtract(const Duration(days: 1)));
  }

  void _tomorrow() {
    _updateDate(currentDate.add(const Duration(days: 1)));
  }

  void _updateDate(DateTime newDate) {
    setState(() {
      currentDate = newDate;
      _updateControllers();
    });
  }

  void _showToDoAdd() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add To-Do'),
          content: TextField(
            controller: todoController,
            decoration: const InputDecoration(labelText: 'Enter...'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addTodo();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addTodo() {
    setState(() {
      if (!todoLists.containsKey(currentDate)) {
        todoLists[currentDate] = [];
      }
      todoLists[currentDate]!.add(TodoItem(todoController.text, TodoState.empty));
      todoController.clear();
    });
  }

  void _updateControllers() {
    todoController.clear();
    memoController.clear();
    if (todoLists.containsKey(currentDate)) {
      todoController.text = todoLists[currentDate]!.map((todoItem) => todoItem.text).join('\n');
    }
    if (memos.containsKey(currentDate)) {
      memoController.text = memos[currentDate]!;
    }
  }

  void _toggleTodoState(int index) {
    setState(() {
      if (todoLists.containsKey(currentDate) && index < todoLists[currentDate]!.length) {
        TodoItem todoItem = todoLists[currentDate]![index];

        if (todoItem.todoState == TodoState.empty) {
          todoItem.todoState = TodoState.checked;
        } else if (todoItem.todoState == TodoState.checked) {
          todoItem.todoState = TodoState.triangular;
        } else {
          todoItem.todoState = TodoState.empty;
        }

        _updateControllers();
      }
    });
  }

  void _deleteTodoItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete To-Do'),
          content: const Text('Are you sure you want to delete this To-Do?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                _performDeleteTodoItem(index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _performDeleteTodoItem(int index) {
    setState(() {
      if (todoLists.containsKey(currentDate) && index < todoLists[currentDate]!.length) {
        todoLists[currentDate]!.removeAt(index);
        _updateControllers();
      }
    });
  }

  IconData _getTodoIcon(TodoItem todoItem) {
    switch (todoItem.todoState) {
      case TodoState.checked:
        return Icons.check_box;
      case TodoState.triangular:
        return Icons.indeterminate_check_box;
      default:
        return Icons.check_box_outline_blank;
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    dataController = widget.dataController;
    return GetBuilder<DataController>(
      builder: (controller) {
        todoLists = controller.todoLists;
        memos = controller.memos;
        memoController.text = memos[currentDate] ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: _yesterday, icon: const Icon(Icons.arrow_back_ios)),
                  Text(formattedDate, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: _tomorrow, icon: const Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('To-Do-List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: _showToDoAdd, icon: const Icon(Icons.add_circle_outline))
                      ]),
                      Expanded(
                        child: ListView.separated(
                          itemCount: todoLists.containsKey(currentDate) ? todoLists[currentDate]!.length : 0,
                          separatorBuilder: (context, index) => const SizedBox(height: 5),
                          itemBuilder: (context, index) {
                            TodoItem todoItem = todoLists[currentDate]![index];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _toggleTodoState(index);
                                      },
                                      child: Icon(
                                        _getTodoIcon(todoItem),
                                        color: _getIconColor(todoItem),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(todoItem.text),
                                  ],
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 1,
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete),
                                          SizedBox(width: 8),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 1) {
                                      _deleteTodoItem(index);
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Text('Memo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: memos.containsKey(currentDate) ? '' : 'Enter...',
                          border: InputBorder.none,
                        ),
                        controller: memoController,
                        onChanged: (value) {
                          setState(() {
                            memos[currentDate] = value;
                          });
                        },
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getIconColor(TodoItem todoItem) {
    switch (todoItem.todoState) {
      case TodoState.checked:
        return Colors.green;
      case TodoState.triangular:
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
