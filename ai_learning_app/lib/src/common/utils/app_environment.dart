enum EnvironmentType { dev, staging, prod }

class AppEnvironment {
  static EnvironmentType current = EnvironmentType.dev;

  static bool get isDev => current == EnvironmentType.dev;
  static bool get isStaging => current == EnvironmentType.staging;
  static bool get isProd => current == EnvironmentType.prod;

  static void setup(EnvironmentType env) {
    current = env;
  }
}
