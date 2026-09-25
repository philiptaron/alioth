{
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "alioth";
  inherit ((lib.importTOML ./alioth-cli/Cargo.toml).package) version;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./alioth
      ./alioth-cli
      ./alioth-macros
      ./serde-aco
      ./serde-aco-derive
    ];
  };

  cargoLock.lockFile = ./Cargo.lock;

  # Checks use `debug_assert_eq!`
  checkType = "debug";

  separateDebugInfo = true;

  meta = {
    homepage = "https://github.com/google/alioth";
    description = "Experimental virtual machine monitor written from scratch in Rust";
    license = lib.licenses.asl20;
    mainProgram = "alioth";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
