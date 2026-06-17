class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://pjjkjnofislpdckjixtg.supabase.co/rest/v1/';

  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqamtqbm9maXNscGRja2ppeHRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNDIxNzUsImV4cCI6MjA5MDcxODE3NX0.7MgVLFScjw0xY5j8c3Uug74MG1WYhzoC5_F_ccPqOiU';

  // Trailing slash required — Dio appends paths without a leading '/'.
  static const String mobileApiBaseUrl = 'https://hamsatech-api.onrender.com/';
}
