// lib/student/category_data.dart

final Map<String, Map<String, int>> departmentData = {
  "Mandatory Courses": {
    "Environmental Studies (mandatory)": 5,
    "Value Education (mandatory)": 5,
    "Indian Constitution (mandatory)": 5,
  },
  "Department Activities": {
    "Department Association - Participation (per activity)": 2,
    "Class Representative (per semester per rep)": 5,
    "Any other activity assigned by FA": 2,
  },
};

final Map<String, Map<String, int>> instituteData = {
  "Research & Conferences": {
    "Presenting paper outside Institute": 10,
    "Presenting paper inside Institute": 5,
    "Participating in conferences/workshops": 3,
  },
  "Clubs & Events": {
    "Prize winners (club events)": 5,
    "Coordinator (event)": 5,
    "Team lead (event)": 3,
    "Student volunteer (event)": 2,
    "Club office bearer (per semester)": 3,
    "Club member (per semester)": 2,
    "SAC Executive Member (per semester)": 10,
  },
  "Competitions": {
    "Institute level competition participation": 5,
    "Institute level competition prize winner": 10,
    "District level participation": 10,
    "District level prize winner": 15,
    "State level participation": 15,
    "State level prize winner": 20,
    "National level participation": 20,
    "National level prize winner": 25,
  },
  "NSS / NCC": {
    "NSS Participation (basic events)": 5,
    "NSS Annual Camp": 20,
    "NCC Institutional training (per semester)": 5,
    "NCC C Certificate Exam (directorate level)": 30,
  },
};
