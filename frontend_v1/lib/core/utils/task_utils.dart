class TaskUtils {
  TaskUtils._();

  static int countToDo(List<Map<String, dynamic>> tasks) {
    var count = 0;
    for (final task in tasks) {
      if (task['completed'] == false) {
        count++;
      }
    }
    return count;
  }
}
