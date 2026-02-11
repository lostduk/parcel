{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    nixpkgs-esp-dev.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-esp-dev, ... }:
    let
      lib = nixpkgs.lib;

      eachSystem = lib.genAttrs [ "x86_64-linux" ];
      pkgsFor = eachSystem (system: import nixpkgs {
        localSystem = system;

        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      });
    in {
      devShells = eachSystem (system: let
        pkgs = pkgsFor.${system};

        androidComposition = pkgs.androidenv.composeAndroidPackages {
          includeNDK = true;

          ndkVersions = [ "28.2.13676358" ];
          platformVersions = [ "36" ];
          buildToolsVersions = [ "35.0.0" ];
          cmakeVersions = [ "3.22.1" ];
        };
        androidSdk = androidComposition.androidsdk;
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # app
            flutter
            androidSdk
            jdk21

            # embedded
            nixpkgs-esp-dev.packages.${system}.esp-idf-full
          ];

          shellHook = ''
            flutter --disable-analytics

            export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
            export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_HOME/build-tools/35.0.0/aapt2 $GRADLE_OPTS"

            echo "Development environment is ready!";
          '';

          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
        };
      });
    };
}
