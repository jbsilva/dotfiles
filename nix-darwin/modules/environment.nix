{ ... }:
{
  # Ensure the system exposes Homebrew's OpenJDK to toolchains.
  environment = {
    variables = {
      JAVA_HOME = "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home";
      JDK_HOME = "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home";
    };

    systemPath = [
      "/opt/homebrew/opt/openjdk/bin"
    ];
  };
}
