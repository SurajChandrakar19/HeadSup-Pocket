// Global performance and attendance data for HomeTabScreen

Map<String, Map<String, dynamic>> globalPerformanceData = {
  'Daily': {
    'joinings': 3,
    'closures': 2,
    'attendance': 1,
    'chartData': [2, 1, 3, 2, 1, 3, 2],
    'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'attendanceData': [8, 7, 8, 6, 8, 0, 0],
  },
  'Weekly': {
    'joinings': 12,
    'closures': 8,
    'attendance': 5,
    'chartData': [8, 12, 15, 10, 18, 12, 20],
    'labels': ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4', 'Wk 5', 'Wk 6', 'Wk 7'],
    'attendanceData': [5, 4, 5, 3, 5, 4, 5],
  },
  'Monthly': {
    'joinings': 45,
    'closures': 32,
    'attendance': 22,
    'chartData': [35, 42, 38, 45, 52, 48, 55],
    'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
    'attendanceData': [22, 20, 23, 18, 24, 21, 25],
  },
};
